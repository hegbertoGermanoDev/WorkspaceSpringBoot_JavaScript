package com.teste.crudspringteste.repository;

import java.util.List;

import javax.persistence.EntityManager;

import com.teste.crudspringteste.model.Arquivo;

import org.springframework.stereotype.Repository;

@Repository
public class ArquivoCustomRepository {
    
    private final EntityManager entityManager;

    public ArquivoCustomRepository(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    public List<Arquivo> listArquivoByFiltros(String tipo, String nomeArquivo, String dataInicial, String dataFinal) {
        
        String query = "Select A From Arquivo as A";
        String condicao = " Where ";
        
        if (tipo != null && tipo != "") {
            query += condicao + " A.tipo = :tipo";
            condicao = " and ";
        }
        if (nomeArquivo != null && nomeArquivo != "") {
            query += condicao + " A.nomeArquivo = :nomeArquivo";
            condicao = " and ";
        }
        
        if ((dataInicial != null && dataFinal != null) && (dataInicial != "" && dataFinal != "")) {
            query += condicao + " A.dtGeracao between '" + dataInicial + "' and '" + dataFinal +"'";
        }
        
        var q = entityManager.createQuery(query, Arquivo.class);

        if (tipo != null && tipo != "") {
            q.setParameter("tipo", tipo);
        }
        if (nomeArquivo != null && nomeArquivo != "") {
            q.setParameter("nomeArquivo", nomeArquivo);
        }

        return q.getResultList();
    }

}
