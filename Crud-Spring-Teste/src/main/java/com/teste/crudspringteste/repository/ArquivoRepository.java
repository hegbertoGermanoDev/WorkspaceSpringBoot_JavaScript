package com.teste.crudspringteste.repository;

import java.util.Date;
import java.util.List;

import com.teste.crudspringteste.model.Arquivo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface ArquivoRepository extends JpaRepository<Arquivo, Long> {
    
    List<Arquivo> findByNomeArquivo(String nomeArquivo);

    @Query(nativeQuery = true, value = "Select * From Arquivo a Where a.tipo = ?1")
    List<Arquivo> findByConsulta(String tipo, String nomeArquivo, Date dataInicial, Date dataFinal);

}
