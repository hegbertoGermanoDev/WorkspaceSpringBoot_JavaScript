package com.teste.crudspringteste.model;

import lombok.Data;

@Data
public class ArquivoVO {
    private String tipo;
    private String nomeArquivo;
    private String dataInicial;
    private String dataFinal;

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

    public String getDataInicial() {
        return this.dataInicial;
    }

    public void setDataInicial(String dataInicial) {
        this.dataInicial = dataInicial;
    }

    public String getDataFinal() {
        return this.dataFinal;
    }

    public void setDataFinal(String dataFinal) {
        this.dataFinal = dataFinal;
    }

}
