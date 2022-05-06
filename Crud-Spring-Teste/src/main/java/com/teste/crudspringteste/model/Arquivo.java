package com.teste.crudspringteste.model;

import java.sql.Blob;
import java.sql.Timestamp;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

import lombok.Data;

@Data
@Entity
public class Arquivo {
    
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Column
    private String banco;

    @Column
    private String tipo;

    @Column
    private String nomeArquivo;
    
    @Column
    private Blob arquivo;
    
    @Column
    private Timestamp dtGeracao;

    @Column
    private String usuarioGeracao;

    @Column
    private Timestamp dtEnvio;
    
    @Column
    private Integer qtdLinhas;
    
    @Column
    private Double vlrTotal;


    public Long getId() {
        return this.id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getBanco() {
        return this.banco;
    }

    public void setBanco(String banco) {
        this.banco = banco;
    }

    public String getTipo() {
        return this.tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getNomeArquivo() {
        return this.nomeArquivo;
    }

    public void setNomeArquivo(String nomeArquivo) {
        this.nomeArquivo = nomeArquivo;
    }
    
    public Blob getArquivo() {
        return this.arquivo;
    }

    public void setArquivo(Blob arquivo) {
        this.arquivo = arquivo;
    }
    
    public Timestamp getDtGeracao() {
        return this.dtGeracao;
    }

    public void setDtGeracao(Timestamp dtGeracao) {
        this.dtGeracao = dtGeracao;
    }

    public String getUsuarioGeracao() {
        return this.usuarioGeracao;
    }

    public void setUsuarioGeracao(String usuarioGeracao) {
        this.usuarioGeracao = usuarioGeracao;
    }

    public Timestamp getDtEnvio() {
        return this.dtEnvio;
    }

    public void setDtEnvio(Timestamp dtEnvio) {
        this.dtEnvio = dtEnvio;
    }

    public Integer getQtdLinhas() {
        return this.qtdLinhas;
    }

    public void setQtdLinhas(Integer qtdLinhas) {
        this.qtdLinhas = qtdLinhas;
    }

    public Double getVlrTotal() {
        return this.vlrTotal;
    }

    public void setVlrTotal(Double vlrTotal) {
        this.vlrTotal = vlrTotal;
    }

}
