package com.example.study.dto.auth;

import java.util.List;

public class SecurityQuestionsResponse {

    private String username;

    private List<SecurityQuestionView> questions;

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public List<SecurityQuestionView> getQuestions() {
        return questions;
    }

    public void setQuestions(List<SecurityQuestionView> questions) {
        this.questions = questions;
    }

    public static class SecurityQuestionView {
        private int order;
        private String question;

        public int getOrder() {
            return order;
        }

        public void setOrder(int order) {
            this.order = order;
        }

        public String getQuestion() {
            return question;
        }

        public void setQuestion(String question) {
            this.question = question;
        }
    }
}

