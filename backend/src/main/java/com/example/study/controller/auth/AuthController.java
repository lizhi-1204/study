package com.example.study.controller.auth;

import com.example.study.dto.auth.*;
import com.example.study.service.auth.AuthService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;

@RestController
@RequestMapping("/api/v1/auth")
@Validated
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/parent/register")
    public AuthResponse registerParent(@Valid @RequestBody ParentRegisterRequest request) {
        return authService.registerParent(request);
    }

    @PostMapping("/parent/login")
    public AuthResponse loginParent(@Valid @RequestBody ParentLoginRequest request) {
        return authService.loginParent(request);
    }

    @PostMapping("/child/login")
    public AuthResponse loginChild(@Valid @RequestBody ChildLoginRequest request) {
        return authService.loginChild(request);
    }

    @GetMapping("/parent/password/security-questions")
    public SecurityQuestionsResponse getSecurityQuestions(@RequestParam("username") String username) {
        return authService.getSecurityQuestions(username);
    }

    @PostMapping("/parent/password/verify-questions")
    public ResetTokenResponse verifyQuestions(@Valid @RequestBody SecurityAnswersVerifyRequest request) {
        String token = authService.verifySecurityAnswers(request);
        ResetTokenResponse response = new ResetTokenResponse();
        response.setResetToken(token);
        // 前端可选使用，具体过期时间逻辑放到实现中
        response.setExpiresInSeconds(600L);
        return response;
    }

    @PostMapping("/parent/password/reset")
    public SimpleSuccessResponse resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        authService.resetPassword(request);
        SimpleSuccessResponse resp = new SimpleSuccessResponse();
        resp.setSuccess(true);
        return resp;
    }
}

