package com.example.gblog.config;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Counter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MonitoringConfig {

  @Bean
  public Counter postCreationCounter(MeterRegistry registry) {
    return Counter.builder("gblog.posts.created")
        .description("Number of posts created")
        .tag("application", "gblog-backend")
        .register(registry);
  }

  @Bean
  public Counter apiErrorCounter(MeterRegistry registry) {
    return Counter.builder("gblog.api.errors")
        .description("Number of API errors")
        .tag("application", "gblog-backend")
        .register(registry);
  }
}
