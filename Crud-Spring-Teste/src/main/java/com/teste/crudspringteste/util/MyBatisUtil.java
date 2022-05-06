package com.teste.crudspringteste.util;

import java.io.IOException;
import java.io.Reader;

import org.apache.ibatis.io.Resources;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;

public class MyBatisUtil {
    
    private static SqlSessionFactory sessionFactory;
    
    static {
        Reader reader;
        try {
            reader = Resources.getResourceAsReader("mybatis-conf.xml");
            sessionFactory = new SqlSessionFactoryBuilder().build(reader);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static SqlSessionFactory getSqlSessionFactory() {
        return sessionFactory;
    }
}
