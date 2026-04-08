package com.example.study.service.auth;

import com.example.study.dto.auth.*;

public interface AuthService {

    AuthResponse registerParent(ParentRegisterRequest request);

    AuthResponse loginParent(ParentLoginRequest request);

    AuthResponse loginChild(ChildLoginRequest request);

    SecurityQuestionsResponse getSecurityQuestions(String username);

    String verifySecurityAnswers(SecurityAnswersVerifyRequest request);

    void resetPassword(ResetPasswordRequest request);
}

