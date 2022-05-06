package com.teste.crudspringteste.dao;

import java.util.List;

import com.teste.crudspringteste.model.Arquivo;
import com.teste.crudspringteste.util.MyBatisUtil;

import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

@Repository
public class ArquivoMapper {

    public List<Arquivo> getAllArquivos() {
        SqlSession session = MyBatisUtil.getSqlSessionFactory().openSession();
        List<Arquivo> arquivoList = session.selectList("getAllArquivos");
        session.commit();
        session.close();
        return arquivoList;
    }

    public List<Arquivo> listArquivosByFiltro(String nomeArquivo, String tipo, String dataInicial, String dataFinal) {
        SqlSession session = MyBatisUtil.getSqlSessionFactory().openSession();
        List<Arquivo> arquivoList = session.selectList("listArquivosByFiltro");
        session.commit();
        session.close();
        return arquivoList;
    }
}
