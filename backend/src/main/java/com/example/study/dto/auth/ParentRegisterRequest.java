package com.example.study.dto.auth;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.NotNull;
import java.util.List;

public class ParentRegisterRequest {

    @NotBlank
    private String username;

    @NotBlank
    private String password;

    private String nickname;

    private String avatarUrl;

    @NotEmpty
    private List<SecurityQuestionDto> securityQuestions;

    @NotNull
    private FirstChildDto firstChild;

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public List<SecurityQuestionDto> getSecurityQuestions() {
        return securityQuestions;
    }

    public void setSecurityQuestions(List<SecurityQuestionDto> securityQuestions) {
        this.securityQuestions = securityQuestions;
    }

    public FirstChildDto getFirstChild() {
        return firstChild;
    }

    public void setFirstChild(FirstChildDto firstChild) {
        this.firstChild = firstChild;
    }
}

