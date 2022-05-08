-- 2579 - Faturas de Intercâmbio a Receber
SELECT codigo_sabius,
       codigo_ebs,
       nome_unimed,
       numero_fatura,
       tipo,
       natureza,
       situacao_fatura,
       mes_competencia,
       ano_competencia,
       data_emissao,
       data_vencimento,
       data_prorrogacao,
       data_cancelamento,
       data_recebimento,
       valor_fatura,
       valor_recebido,
       valor_desconto,
       valor_a_receber,
       situacao,
       dt_envio_suspensao,
       dt_suspensao,
       status,
       tipo_sing_fed,
       tipo_pgto,
       lote,
       valor_lote,
       vencto_lote

  FROM (
        
        SELECT distinct SUBSTR(UN.CGC_UNIMED, 1, 8) CODIGO_EBS,
                         'Intercambio' IDENTIFICADOR, --TIPO
                         fu.cod_unimed CODIGO_SABIUS, --COD_UNIMED / EMPRESA
                         un.nome_completo NOME_UNIMED, --NOME
                         f.numero_fatura, --NUMERO FATURA
                         'FATURA' TIPO,
                         f.natureza_fatura NATUREZA,
                         decode(f.situacao_fatura,
                                'F',
                                'Aberta',
                                'P',
                                'Parcial',
                                'L',
                                'Liquidada',
                                'C',
                                'Cancelada') SITUACAO_FATURA, -- SITUACAO FATURA
                         (select to_char(tr.data_recebimento, 'dd/mm/yyyy')
                            from titulos_recebidos tr
                           where tr.unimed_emitente = f.unimed_producao
                             and tr.num_doc_origem = f.numero_fatura
                             and tr.data_cancel_baixa is null
                             and tr.cod_recebimento =
                                 (select max(tr1.cod_recebimento)
                                    from titulos_recebidos tr1
                                   where tr.unimed_emitente =
                                         tr1.unimed_emitente
                                     and tr.num_doc_origem = tr1.num_doc_origem
                                     and tr1.data_cancel_baixa is null)
                          
                          ) DATA_RECEBIMENTO,
                         f.data_emissao, -- EMISSÃO
                         f.data_vencimento, -- VENCIMENTO
                         pd.data_prorrog data_prorrogacao,
                         f.valor_fatura, -- VALOR
                         (SELECT Sum(t.valor_recebido) -
                                 Sum(t.valor_juros_multa)
                            FROM fatura f1, titulos_recebidos t
                           WHERE f1.unimed_producao = 63
                             AND f1.tipo_fatura = 'U'
                             AND (('S' = 'N' AND
                                 (F.SITUACAO_FATURA <> 'C')) OR
                                 'S' = 'S')
                                
                             AND (
                                 
                                  ('S' = 'N' AND
                                  (f.situacao_fatura <> 'L')
                                  
                                  ) OR 'S' = 'S')
                             AND t.unimed_emitente = f1.unimed_producao
                             AND t.cod_tipo_doc_origem = 3
                             AND t.num_doc_origem = f1.numero_fatura
                             AND f1.numero_fatura = f.numero_fatura
                             AND T.DATA_CANCEL_BAIXA IS NULL) VALOR_RECEBIDO, -- VL RECEBIDO
                         
                         (SELECT Sum(d.valor_desconto)
                            FROM fatura f1, descontos_documentos d
                           WHERE f1.unimed_producao = 63
                             AND f1.tipo_fatura = 'U'
                             AND (('S' = 'N' AND
                                 (F.SITUACAO_FATURA <> 'C')) OR
                                 'S' = 'S')
                                
                             AND (
                                 
                                  ('S' = 'N' AND
                                  (f.situacao_fatura <> 'L')) OR
                                  'S' = 'S')
                             AND d.cod_unimed = f1.unimed_producao
                             AND d.cod_tipo_doc = 3
                             AND d.num_doc = f1.numero_fatura
                             AND f1.numero_fatura = f.numero_fatura
                             AND D.DATA_CANC_DESC IS NULL
                          
                          ) VALOR_DESCONTO, -- VL DESCONTO
                         
                         (f.valor_fatura -
                         (SELECT nvl(Sum(t.valor_recebido) -
                                      Sum(t.valor_juros_multa),
                                      0)
                             FROM fatura f1, titulos_recebidos t
                            WHERE f1.unimed_producao = 63
                              AND f1.tipo_fatura = 'U'
                              AND (('S' = 'N' AND
                                  (F.SITUACAO_FATURA <> 'C')) OR
                                  'S' = 'S')
                              AND (
                                  
                                   ('S' = 'N' AND
                                   (f.situacao_fatura <> 'L')) OR
                                   'S' = 'S')
                                 
                              AND t.unimed_emitente = f1.unimed_producao
                              AND t.cod_tipo_doc_origem = 3
                              AND t.num_doc_origem = f1.numero_fatura
                              AND f1.numero_fatura = f.numero_fatura
                              AND T.DATA_CANCEL_BAIXA IS NULL) -
                         (SELECT nvl(Sum(d.valor_desconto), 0)
                             FROM fatura f1, descontos_documentos d
                            WHERE f1.unimed_producao = 63
                              AND f1.tipo_fatura = 'U'
                                 
                              AND (('S' = 'N' AND
                                  (F.SITUACAO_FATURA <> 'C')) OR
                                  'S' = 'S')
                                 
                              AND (
                                  
                                   ('S' = 'N' AND
                                   (f.situacao_fatura <> 'L')) OR
                                   'S' = 'S')
                                 
                              AND d.cod_unimed = f1.unimed_producao
                              AND d.cod_tipo_doc = 3
                              AND d.num_doc = f1.numero_fatura
                              AND f1.numero_fatura = f.numero_fatura
                              AND D.DATA_CANC_DESC IS NULL)) VALOR_A_RECEBER, -- VALOR A RECEBER
                         CASE
                           WHEN ((Select count(*)
                                    from unimeds u
                                   where u.cod_unimed = fu.cod_unimed
                                     and u.data_exclusao is not null
                                     and u.data_exclusao <=
                                         To_Date('01/01/2018', 'DD/MM/YYYY')) > 0) then
                            'Excluido'
                           WHEN ((SELECT count(*)
                                    FROM atendimentos_unimeds_suspensos au
                                   WHERE au.cod_unimed_atendimento =
                                         f.unimed_producao --ta.unimed_producao
                                     AND au.cod_unimed_suspensa = un.cod_unimed
                                     AND au.data_inicial =
                                         (SELECT Max(au1.data_inicial)
                                            FROM atendimentos_unimeds_suspensos au1
                                           WHERE au1.cod_unimed_atendimento =
                                                 au.cod_unimed_atendimento
                                             AND au1.cod_unimed_suspensa =
                                                 au.cod_unimed_suspensa
                                             and au1.data_inicial <=
                                                 To_Date('01/01/2018',
                                                         'DD/MM/YYYY'))
                                     AND au.data_final >
                                         To_Date('01/01/2018', 'DD/MM/YYYY')) > 0) then
                            'Suspenso'
                           ELSE
                            'Ativo'
                         END AS Situacao,
                         0 qtd_vidas,
                         f.ano_fatura ANO_COMPETENCIA,
                         f.mes_fatura MES_COMPETENCIA,
                         f.data_cancelamento,
                         sabius.geral.PROXIMO_DIA_UTIL('CE',
                                                       9533,
                                                       f.data_vencimento + 10,
                                                       'B') dt_envio_suspensao,
                         sabius.geral.PROXIMO_DIA_UTIL('CE',
                                                       9533,
                                                       f.data_vencimento + 21,
                                                       'B') dt_suspensao,
                         (select case
                                   when count(*) > 0 then
                                    'ATENDIMENTO SUSPENSO'
                                   else
                                    'ATIVO'
                                 end
                            from ATENDIMENTOS_UNIMEDS_SUSPENSOS au
                           where au.cod_unimed_atendimento = fu.unimed_producao
                             and au.cod_unimed_suspensa = fu.cod_unimed
                             and to_date(to_char(sysdate, 'dd/mm/yyyy'),
                                         'dd/mm/yyyy') between
                                 to_date(to_char(au.data_inicial, 'dd/mm/yyyy'),
                                         'dd/mm/yyyy') and
                                 to_date(to_char(nvl(au.data_final, sysdate),
                                                 'dd/mm/yyyy'),
                                         'dd/mm/yyyy')) status,
                         (select tp.desc_tipo
                            from unimeds u1, tp_singular_federacao_unimed tp
                           where u1.cod_unimed = fu.cod_unimed
                             and tp.cod_tipo_sing_fed_uni =
                                 u1.cod_tipo_sing_fed_uni) tipo_sing_fed,
                         (select decode(u1.tipo_pgto_intercambio,
                                        'CNL',
                                        'Câmara da Unimed do Brasil',
                                        'PD',
                                        'Pagamentos Direto',
                                        'EC',
                                        'Encontro de Contas',
                                        u1.tipo_pgto_intercambio)
                            from unimeds u1
                           where u1.cod_unimed = fu.cod_unimed) tipo_pgto,
                         (select replace(to_char(wm_concat(l.num_lote)),
                                         ',',
                                         ';')
                            from lote_pgto_doc l
                           where l.unimed_producao = f.unimed_producao
                             and l.cod_tipo_doc_origem = 3
                             and l.num_doc_origem = f.numero_fatura) lote,
                         (select nvl(sum(l.saldo_lote), 0)
                            from lote_pgto_doc l
                           where l.unimed_producao = 63 --and l.cod_tipo_doc_origem = 3 --and l.num_doc_origem = 1637062019
                             and l.num_lote in
                                 (select l1.num_lote
                                    from lote_pgto_doc l1
                                   where l1.unimed_producao = 63
                                     and l1.num_doc_origem = f.numero_fatura)) valor_lote,
                         (select replace(to_char(wm_concat(l.vencimento_lote)),
                                         ',',
                                         ';')
                            from lote_pgto_doc l
                           where l.unimed_producao = f.unimed_producao
                             and l.cod_tipo_doc_origem = 3
                             and l.num_doc_origem = f.numero_fatura) vencto_lote
        
          FROM fatura        f,
                fatura_unimed fu,
                unimeds       un,
                --ver_enderecos             en,
                titulos_recebidos t,
                --local_pgto                l,
                --motivo_baixa              m,
                --tipos_doc_operacao_financ td,
                prorrogacoes_documentos pd --,
        --UNIMEDS                   U
         WHERE F.UNIMED_PRODUCAO = 63 --and f.numero_fatura = 126422016
           AND f.tipo_fatura = 'U'
           AND (
               --não esteja cancelada ou que o cancelamento tenha sido após a data_base
                ('S' = 'N' AND (F.SITUACAO_FATURA <> 'C')) OR
                'S' = 'S')
              
              --não esteja liquidada ou que a última baixa tenha sido após a data_base 
              
           AND (('S' = 'N' AND
               (f.situacao_fatura <> 'L' OR
               (f.situacao_fatura = 'L' AND
               (SELECT trunc(max(tr1.data_recebimento))
                      FROM titulos_recebidos tr1
                     WHERE tr1.num_doc_origem = f.numero_fatura
                       AND tr1.unimed_emitente = f.unimed_producao
                       AND tr1.cod_tipo_doc_origem = 3
                       AND tr1.data_cancel_baixa IS NULL) >
               To_Date('01/01/2018', 'DD/MM/YYYY')))) OR
               'S' = 'S')
           and (('E' = 'V' AND
               (To_Date(To_Char(f.data_vencimento, 'DD/MM/YYYY'),
                          'DD/MM/YYYY') >=
               To_Date('01/01/2018', 'DD/MM/YYYY')) OR
               'E' = 'E' AND
               (f.data_emissao >= To_Date('01/01/2018', 'DD/MM/YYYY')) OR
               'E' = 'C' AND
               (F.MES_FATURA = TO_char(to_date('01/01/2018'), 'MM') AND
               F.ANO_FATURA = TO_char(to_date('01/01/2018'), 'YYYY')
               
               )))
              
           AND fu.unimed_producao = f.unimed_producao
           AND fu.numero_fatura = f.numero_fatura
           AND un.cod_unimed = fu.cod_unimed
              --and en.cod_endereco = un.cod_endereco
           and t.unimed_emitente(+) = f.unimed_producao
           and t.cod_tipo_doc_origem(+) = 3
           and t.num_doc_origem(+) = f.numero_fatura
           and t.data_cancel_baixa IS NULL
              --and l.cod_local_pgto(+) = t.cod_local_receb
              --and m.cod_mot_baixa(+) = t.cod_motivo_baixa
              --and td.codigo(+) = t.cod_tipo_doc_op_financ
           and pd.cod_unimed(+) = f.unimed_producao
           and pd.num_doc(+) = f.numero_fatura
           and pd.cod_tipo_doc(+) = 3
           and pd.ind_status_prorrog(+) = 'L'
              --AND U.COD_UNIMED = F.UNIMED_PRODUCAO
           AND T.DATA_CANCEL_BAIXA IS NULL
        
        UNION
        
        SELECT distinct SUBSTR(UN.CGC_UNIMED, 1, 8) CODIGO_EBS,
                        'Intercambio-NC' IDENTIFICADOR, --TIPO @@@@@@@@@@@@@@@@@@@@@
                        un.cod_unimed, --COD_UNIMED / EMPRESA @@@@@@@@@@@@@@@@@@@@@@@@
                        un.nome_completo CODIGO_SABIUS, --NOME @@@@@@@@@@@@@@@@@@@@@@@@
                        ta.num_titulo_avulso, -- NUMERO FATURA@@@@@@@@@@@@@@@@@@@@@@
                        'NDC' TIPO,
                        'N/A' NATUREZA,
                        decode(ta.status,
                               'F',
                               'Aberta',
                               'P',
                               'Parcial',
                               'L',
                               'Liquidada',
                               'C',
                               'Cancelada') SITUACAO_FATURA, -- SITUACAO FATURA@@@@@@@@@@@@@@@@@@@@@@
                        (select to_char(tr.data_recebimento, 'dd/mm/yyyy')
                           from titulos_recebidos tr
                          where tr.unimed_emitente = ta.unimed_producao
                            and tr.num_doc_origem = ta.num_titulo_avulso
                            and tr.data_cancel_baixa is null
                            and tr.cod_recebimento =
                                (select max(tr1.cod_recebimento)
                                   from titulos_recebidos tr1
                                  where tr.unimed_emitente =
                                        tr1.unimed_emitente
                                    and tr.num_doc_origem = tr1.num_doc_origem
                                    and tr1.data_cancel_baixa is null)
                         
                         ) DATA_RECEBIMENTO,
                        ta.data_emissao, -- EMISSÃO@@@@@@@@@@@@@@@@@@@@@
                        ta.data_vencimento, -- VENCIMENTO @@@@@@@@@@@@@@@@@              
                        pd.data_prorrog DATA_PRORROGACAO,
                        ta.valor_total, -- VALOR @@@@@@@@@@@@@@@@@@@@@@@@@@
                        (SELECT Sum(t.valor_recebido) -
                                Sum(t.valor_juros_multa)
                           FROM titulo_avulso tav, titulos_recebidos t
                          WHERE tav.unimed_producao = 63
                               -- AND tav.status NOT IN ('C','L')
                            AND (('S' = 'N' AND (tav.status <> 'C')) OR
                                'S' = 'S')
                               
                            AND (('S' = 'N' AND (tav.status <> 'L')
                                
                                ) OR 'S' = 'S')
                               
                            AND t.unimed_emitente = tav.unimed_producao
                            AND t.cod_tipo_doc_origem = 36
                            AND tav.cod_tipo_origem IN (41, 83)
                            AND t.num_doc_origem = tav.num_titulo_avulso
                            AND tav.num_titulo_avulso = ta.num_titulo_avulso
                            and t.data_cancel_baixa is null
                         
                         ) VALOR_RECEBIDO, -- VL RECEBIDO
                        
                        (SELECT sum(dd.valor_desconto)
                           FROM descontos_documentos dd
                          WHERE dd.cod_unimed(+) = ta.unimed_producao
                            and dd.num_doc(+) = ta.num_titulo_avulso
                            and dd.cod_tipo_doc(+) = 36
                            and dd.ind_status_desc(+) = 'L'
                            AND DD.DATA_CANC_DESC IS NULL) DESCONTO, -- VL DESCONTO @@@@@@@@@@@@@@@@@@@@@
                        
                        (ta.valor_total -
                        
                        (SELECT nvl(Sum(t.valor_recebido) -
                                     Sum(t.valor_juros_multa),
                                     0)
                            FROM titulo_avulso tav, titulos_recebidos t
                           WHERE tav.unimed_producao = 63
                             AND tav.cod_tipo_origem IN (41, 83)
                             AND (('S' = 'N' AND (tav.status <> 'C')
                                 
                                 ) OR 'S' = 'S')
                                
                             AND (('S' = 'N' AND (tav.status <> 'L')
                                 
                                 ) OR 'S' = 'S')
                                
                             AND t.unimed_emitente = tav.unimed_producao
                             AND t.cod_tipo_doc_origem = 36
                             AND t.num_doc_origem = tav.num_titulo_avulso
                             AND tav.num_titulo_avulso = ta.num_titulo_avulso
                             AND T.DATA_CANCEL_BAIXA IS NULL) -
                        
                        (SELECT nvl(sum(dd.valor_desconto), 0)
                            FROM descontos_documentos dd
                           WHERE dd.cod_unimed(+) = ta.unimed_producao
                             and dd.num_doc(+) = ta.num_titulo_avulso
                             and dd.cod_tipo_doc(+) = 36
                             and dd.ind_status_desc(+) = 'L'
                             AND DD.DATA_CANC_DESC IS NULL)) VALOR_A_RECEBER, -- VALOR A RECEBER @@@@@@@@@@@@@@@@@@@
                        CASE
                          WHEN ((Select count(*)
                                   from unimeds u
                                  where u.cod_unimed = un.cod_unimed
                                    and u.data_exclusao is not null
                                    and u.data_exclusao <=
                                        To_Date('01/01/2018', 'DD/MM/YYYY')) > 0) then
                           'Excluido'
                          WHEN ((SELECT count(*)
                                   FROM atendimentos_unimeds_suspensos au
                                  WHERE au.cod_unimed_atendimento =
                                        ta.unimed_producao
                                    AND au.cod_unimed_suspensa = un.cod_unimed
                                    AND au.data_inicial =
                                        (SELECT Max(au1.data_inicial)
                                           FROM atendimentos_unimeds_suspensos au1
                                          WHERE au1.cod_unimed_atendimento =
                                                au.cod_unimed_atendimento
                                            AND au1.cod_unimed_suspensa =
                                                au.cod_unimed_suspensa
                                            and au1.data_inicial <=
                                                To_Date('01/01/2018',
                                                        'DD/MM/YYYY'))
                                    AND au.data_final > '01/01/2018') > 0) then
                           'Suspenso'
                          ELSE
                           'Ativo'
                        END AS SITUACAO, -- Situação  @@@@@@@@@@@@@@@@ 
                        
                        0 qtd_vidas,
                        ta.ano_competencia ANO_COMPETENCIA,
                        ta.mes_competencia MES_COMPETENCIA,
                        ta.data_cancel,
                        sabius.geral.PROXIMO_DIA_UTIL('CE',
                                                      9533,
                                                      ta.data_vencimento + 10,
                                                      'B') dt_envio_suspensao,
                        sabius.geral.PROXIMO_DIA_UTIL('CE',
                                                      9533,
                                                      ta.data_vencimento + 21,
                                                      'B') dt_suspensao,
                        (select case
                                  when count(*) > 0 then
                                   'ATENDIMENTO SUSPENSO'
                                  else
                                   'ATIVO'
                                end
                           from ATENDIMENTOS_UNIMEDS_SUSPENSOS au
                          where au.cod_unimed_atendimento = ta.unimed_producao
                            and au.cod_unimed_suspensa = un.cod_unimed
                            and to_date(to_char(sysdate, 'dd/mm/yyyy'),
                                        'dd/mm/yyyy') between
                                to_date(to_char(au.data_inicial, 'dd/mm/yyyy'),
                                        'dd/mm/yyyy') and
                                to_date(to_char(nvl(au.data_final, sysdate),
                                                'dd/mm/yyyy'),
                                        'dd/mm/yyyy')) status,
                        (select tp.desc_tipo
                           from unimeds u1, tp_singular_federacao_unimed tp
                          where u1.cod_unimed = un.cod_unimed
                            and tp.cod_tipo_sing_fed_uni =
                                u1.cod_tipo_sing_fed_uni) tipo_sing_fed,
                        (select decode(u1.tipo_pgto_intercambio,
                                       'CNL',
                                       'Câmara da Unimed do Brasil',
                                       'PD',
                                       'Pagamentos Direto',
                                       'EC',
                                       'Encontro de Contas',
                                       u1.tipo_pgto_intercambio)
                           from unimeds u1
                          where u1.cod_unimed = un.cod_unimed) tipo_pgto,
                        
                        (select replace(to_char(wm_concat(l.num_lote)),
                                        ',',
                                        ';')
                           from lote_pgto_doc l
                          where l.unimed_producao = ta.unimed_producao
                            and l.cod_tipo_doc_origem = 36
                            and l.num_doc_origem = ta.num_titulo_avulso) lote,
                        (select nvl(sum(l.saldo_lote), 0)
                           from lote_pgto_doc l
                          where l.unimed_producao = ta.unimed_producao --and l.cod_tipo_doc_origem = 36 --and l.num_doc_origem = ta.num_titulo_avulso
                            and l.num_lote in
                                (select l1.num_lote
                                   from lote_pgto_doc l1
                                  where l1.unimed_producao = 63
                                    and l1.num_doc_origem =
                                        ta.num_titulo_avulso)) valor_lote,
                        (select replace(to_char(wm_concat(l.vencimento_lote)),
                                        ',',
                                        ';')
                           from lote_pgto_doc l
                          where l.unimed_producao = ta.unimed_producao
                            and l.cod_tipo_doc_origem = 36
                            and l.num_doc_origem = ta.num_titulo_avulso) vencto_lote
        
          FROM titulo_avulso    ta,
               unimeds          un,
               emit_sac_unimeds eu,
               --ver_enderecos             en,
               titulos_recebidos t,
               --local_pgto                l,
               --motivo_baixa              m,
               --tipos_doc_operacao_financ td,
               prorrogacoes_documentos pd --,
        --UNIMEDS                   U
         WHERE ta.unimed_producao = 63
           AND ta.cod_tipo_origem IN (41, 83)
              
           AND (('S' = 'N' AND
               (
               --não esteja cancelada ou que o cancelamento tenha sido após a data_base
                (ta.status <> 'C' OR
                (ta.status = 'C' AND trunc(ta.data_cancel) >
                To_Date('01/01/2018', 'DD/MM/YYYY')))) OR
               'S' = 'S'))
              
              --não esteja liquidada ou que a última baixa tenha sido após a data_base 
           AND (('S' = 'N' AND
               (ta.status <> 'L' OR
               (ta.status = 'L' AND
               (SELECT trunc(max(tr1.data_recebimento))
                      FROM titulos_recebidos tr1
                     WHERE tr1.num_doc_origem = ta.num_titulo_avulso
                       AND tr1.unimed_emitente = ta.unimed_producao
                       AND tr1.cod_tipo_doc_origem = 36
                       AND tr1.data_cancel_baixa IS NULL) >
               To_Date('01/01/2018', 'DD/MM/YYYY')))) OR
               'S' = 'S')
              
           and (('E' = 'V' AND
               (To_Date(To_Char(ta.data_vencimento, 'DD/MM/YYYY'),
                          'DD/MM/YYYY') >=
               To_Date('01/01/2018', 'DD/MM/YYYY')) OR
               'E' = 'E' AND
               (ta.data_emissao >= To_Date('01/01/2018', 'DD/MM/YYYY')) OR
               'E' = 'C' AND
               (TA.MES_COMPETENCIA = TO_char(to_date('01/01/2018'), 'MM') AND
               TA.ANO_COMPETENCIA =
               TO_char(to_date('01/01/2018'), 'YYYY')
               
               )))
           AND eu.cod_emitente_sacado = ta.cod_emitente_sacado
           AND un.cod_unimed = eu.cod_unimed
              --and en.cod_endereco = un.cod_endereco
           and t.unimed_emitente(+) = ta.unimed_producao
           and t.cod_tipo_doc_origem(+) = 36
           and t.num_doc_origem(+) = ta.num_titulo_avulso
           and t.data_cancel_baixa IS NULL
              --and l.cod_local_pgto(+) = t.cod_local_receb
              --and m.cod_mot_baixa(+) = t.cod_motivo_baixa
              --and td.codigo(+) = t.cod_tipo_doc_op_financ
           and pd.cod_unimed(+) = ta.unimed_producao
           and pd.num_doc(+) = ta.num_titulo_avulso
           and pd.cod_tipo_doc(+) = 36
           and pd.ind_status_prorrog(+) = 'L'
              --AND U.COD_UNIMED = TA.UNIMED_PRODUCAO
           and t.data_cancel_baixa is null
        
         ORDER BY 1, 2, 3
        
        );
