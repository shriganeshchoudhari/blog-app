package com.example.gblog.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;


@Configuration
public class DataSourceConfig {
  @Bean
  public DataSource dataSource() {
    String url = System.getenv("SPRING_DATASOURCE_URL");
    String user = System.getenv("SPRING_DATASOURCE_USERNAME");
    String pass = System.getenv("SPRING_DATASOURCE_PASSWORD");

    HikariConfig config = new HikariConfig();
    if (url != null && url.startsWith("jdbc:postgresql://")) {
      config.setJdbcUrl(url);
      config.setDriverClassName("org.postgresql.Driver");
      config.setUsername(user);
      config.setPassword(pass);
    } else {
      // fallback to H2 unless a Postgres URL is provided
      config.setJdbcUrl("jdbc:h2:mem:gblogdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE");
      config.setDriverClassName("org.h2.Driver");
      config.setUsername("sa");
      config.setPassword("");
    }
    return new HikariDataSource(config);
  }
}
