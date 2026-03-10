package com.sena.test.security.dto;

public class UserDTO {
    private Long id;
    private String username;
    private Boolean active;
    private Long personId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }

    public Long getPersonId() { return personId; }
    public void setPersonId(Long personId) { this.personId = personId; }
}