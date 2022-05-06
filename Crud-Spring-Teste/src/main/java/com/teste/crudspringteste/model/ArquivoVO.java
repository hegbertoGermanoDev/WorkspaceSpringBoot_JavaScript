package com.teste.crudspringteste.model;

import java.util.Date;

import lombok.Data;

@Data
public class ArquivoVO {
    private String tipo;
    private String nomeArquivo;
    private Date dataInicial;
    private Date dataFinal;

    public String getTipo() {
        return this.tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getNomeArqvuivo() {
        return this.nomeArquivo;
    }

    public void setNomeArqvuivo(String nomeArqvuivo) {
        this.nomeArquivo = nomeArqvuivo;
    }

    public Date getDataInicial() {
        return this.dataInicial;
    }

    public void setDataInicial(Date dataInicial) {
        this.dataInicial = dataInicial;
    }

    public Date getDataFinal() {
        return this.dataFinal;
    }

    public void setDataFinal(Date dataFinal) {
        this.dataFinal = dataFinal;
    }

}
