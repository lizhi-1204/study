package com.example.study.dto.auth;

import java.util.List;

public class AuthResponse {

    private String token;
    private SimpleUserView parent;
    private SimpleUserView currentChild;
    private List<SimpleUserView> children;

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public SimpleUserView getParent() {
        return parent;
    }

    public void setParent(SimpleUserView parent) {
        this.parent = parent;
    }

    public SimpleUserView getCurrentChild() {
        return currentChild;
    }

    public void setCurrentChild(SimpleUserView currentChild) {
        this.currentChild = currentChild;
    }

    public List<SimpleUserView> getChildren() {
        return children;
    }

    public void setChildren(List<SimpleUserView> children) {
        this.children = children;
    }

    public static class SimpleUserView {
        private Long id;
        private String username;
        private String nickname;
        private String avatarUrl;

        public Long getId() {
            return id;
        }

        public void setId(Long id) {
            this.id = id;
        }

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
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
    }
}

