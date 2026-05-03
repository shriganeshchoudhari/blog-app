package com.example.gblog.itest;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.*;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.HashMap;
import java.util.Map;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@org.springframework.test.context.TestPropertySource(locations = "classpath:application-test.properties")
public class E2ETest {
  @LocalServerPort
  private int port;

  @Autowired
  private TestRestTemplate restTemplate;

  private String baseUrl() {
    return "http://localhost:" + port + "/api/v1";
  }

  private String loginAndGetToken() {
    String url = baseUrl() + "/auth/login";
    Map<String, String> payload = new HashMap<>();
    payload.put("username", "admin");
    payload.put("password", "password");
    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(MediaType.APPLICATION_JSON);
    HttpEntity<Map<String, String>> req = new HttpEntity<>(payload, headers);
    
    // Using ParameterizedTypeReference or explicit Map<String, Object> cast
    ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(url, HttpMethod.POST, req, new org.springframework.core.ParameterizedTypeReference<Map<String, Object>>() {});
    
    assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.OK);
    Map<String, Object> body = resp.getBody();
    assertThat(body).isNotNull();
    return (String) body.get("token");
  }

  @Test
  void fullCrudFlow() {
    String token = loginAndGetToken();
    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(MediaType.APPLICATION_JSON);
    headers.set("Authorization", "Bearer " + token);

    // Create Post
    Map<String, Object> post = new HashMap<>();
    post.put("title", "Phase 3 E2E Post");
    post.put("content", "Content for e2e test post");
    post.put("summary", "Phase 3 seed");
    post.put("status", "draft");
    HttpEntity<Map<String, Object>> createReq = new HttpEntity<>(post, headers);
    ResponseEntity<Map<String, Object>> createResp = restTemplate.exchange(baseUrl() + "/posts", HttpMethod.POST, createReq, new org.springframework.core.ParameterizedTypeReference<Map<String, Object>>() {});
    
    assertThat(createResp.getStatusCode()).isIn(HttpStatus.OK, HttpStatus.CREATED);
    Map<String, Object> created = createResp.getBody();
    assertThat(created).containsKey("id");
    Object postId = created.get("id");

    // Get all posts
    HttpEntity<Void> getAllReq = new HttpEntity<>(headers);
    ResponseEntity<Object> listResp = restTemplate.exchange(baseUrl() + "/posts", HttpMethod.GET, getAllReq, Object.class);
    assertThat(listResp.getStatusCode()).isEqualTo(HttpStatus.OK);

    // Get by id
    ResponseEntity<Map<String, Object>> byIdResp = restTemplate.exchange(baseUrl() + "/posts/" + postId, HttpMethod.GET, getAllReq, new org.springframework.core.ParameterizedTypeReference<Map<String, Object>>() {});
    assertThat(byIdResp.getStatusCode()).isEqualTo(HttpStatus.OK);

    // Update
    Map<String, Object> update = new HashMap<>();
    update.put("title", "Updated E2E Post");
    HttpEntity<Map<String, Object>> updateReq = new HttpEntity<>(update, headers);
    ResponseEntity<Map<String, Object>> updateResp = restTemplate.exchange(baseUrl() + "/posts/" + postId, HttpMethod.PUT, updateReq, new org.springframework.core.ParameterizedTypeReference<Map<String, Object>>() {});
    assertThat(updateResp.getStatusCode()).isEqualTo(HttpStatus.OK);

    // Delete
    ResponseEntity<Void> delResp = restTemplate.exchange(baseUrl() + "/posts/" + postId, HttpMethod.DELETE, getAllReq, Void.class);
    assertThat(delResp.getStatusCode()).isIn(HttpStatus.NO_CONTENT, HttpStatus.OK);
  }
}
