package com.example.study.service.auth;

import com.example.study.dto.auth.*;
import com.example.study.security.JwtTokenUtil;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.Arrays;

@Service
public class AuthServiceImpl implements AuthService {

    private final JdbcTemplate jdbcTemplate;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenUtil jwtTokenUtil;

    public AuthServiceImpl(JdbcTemplate jdbcTemplate, PasswordEncoder passwordEncoder, JwtTokenUtil jwtTokenUtil) {
        this.jdbcTemplate = jdbcTemplate;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenUtil = jwtTokenUtil;
    }

    @Override
    @Transactional
    public AuthResponse registerParent(ParentRegisterRequest request) {
        if (request.getSecurityQuestions() == null || request.getSecurityQuestions().size() != 3) {
            throw new IllegalArgumentException("securityQuestions must contain 3 items");
        }
        if (request.getFirstChild() == null) {
            throw new IllegalArgumentException("firstChild is required");
        }

        String parentUsername = request.getUsername();
        String parentPasswordHash = passwordEncoder.encode(request.getPassword());
        String parentNickname = request.getNickname() == null ? "" : request.getNickname();
        String parentAvatarUrl = request.getAvatarUrl() == null ? "" : request.getAvatarUrl();

        // 1) create parent user
        Long parentUserId = insertUser("PARENT", parentUsername, parentPasswordHash, parentNickname, parentAvatarUrl);

        // 2) create 3 security questions (answers stored as BCrypt hash)
        for (SecurityQuestionDto q : request.getSecurityQuestions()) {
            String answerHash = passwordEncoder.encode(q.getAnswer());
            jdbcTemplate.update(
                    "INSERT INTO parent_security_question(parent_user_id, question_order, question_text, answer_hash) VALUES (?,?,?,?)",
                    parentUserId, q.getOrder(), q.getQuestion(), answerHash
            );
        }

        // 3) create first child user
        FirstChildDto child = request.getFirstChild();
        if (child.getBirthday() == null) {
            throw new IllegalArgumentException("firstChild.birthday is required");
        }

        String childUsername = child.getUsername();
        String childPasswordHash = passwordEncoder.encode(child.getPassword());
        String childNickname = child.getNickname() == null ? "" : child.getNickname();
        String childAvatarUrl = child.getAvatarUrl() == null ? "" : child.getAvatarUrl();

        Long childUserId = insertUser("CHILD", childUsername, childPasswordHash, childNickname, childAvatarUrl);

        // 4) create child profile
        LocalDate birthday = LocalDate.parse(child.getBirthday());
        jdbcTemplate.update(
                "INSERT INTO child_profile(child_user_id, parent_user_id, real_name, birthday) VALUES (?,?,?,?)",
                childUserId, parentUserId, child.getRealName(), Date.valueOf(birthday)
        );

        // 5) return auto-login auth response (PARENT token)
        AuthResponse authResponse = new AuthResponse();
        authResponse.setToken(jwtTokenUtil.generateToken(parentUserId, "PARENT"));

        AuthResponse.SimpleUserView parentView = new AuthResponse.SimpleUserView();
        parentView.setId(parentUserId);
        parentView.setUsername(parentUsername);
        parentView.setNickname(parentNickname);
        parentView.setAvatarUrl(parentAvatarUrl);
        authResponse.setParent(parentView);

        AuthResponse.SimpleUserView childView = new AuthResponse.SimpleUserView();
        childView.setId(childUserId);
        childView.setUsername(childUsername);
        childView.setNickname(childNickname);
        childView.setAvatarUrl(childAvatarUrl);
        authResponse.setCurrentChild(childView);
        authResponse.setChildren(Arrays.asList(childView));

        return authResponse;
    }

    @Override
    public AuthResponse loginParent(ParentLoginRequest request) {
        throw new UnsupportedOperationException("loginParent not implemented yet");
    }

    @Override
    public AuthResponse loginChild(ChildLoginRequest request) {
        throw new UnsupportedOperationException("loginChild not implemented yet");
    }

    @Override
    public SecurityQuestionsResponse getSecurityQuestions(String username) {
        throw new UnsupportedOperationException("getSecurityQuestions not implemented yet");
    }

    @Override
    public String verifySecurityAnswers(SecurityAnswersVerifyRequest request) {
        throw new UnsupportedOperationException("verifySecurityAnswers not implemented yet");
    }

    @Override
    public void resetPassword(ResetPasswordRequest request) {
        throw new UnsupportedOperationException("resetPassword not implemented yet");
    }

    private Long insertUser(String role, String username, String passwordHash, String nickname, String avatarUrl) {
        String sql = "INSERT INTO users(role, username, password_hash, nickname, avatar_url) VALUES (?,?,?,?,?)";
        KeyHolder keyHolder = new GeneratedKeyHolder();

        try {
            jdbcTemplate.update(connection -> {
                PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, role);
                ps.setString(2, username);
                ps.setString(3, passwordHash);
                ps.setString(4, nickname);
                ps.setString(5, avatarUrl);
                return ps;
            }, keyHolder);
        } catch (DuplicateKeyException e) {
            // username unique constraint
            throw new IllegalArgumentException("username already exists");
        }

        Number key = keyHolder.getKey();
        if (key == null) {
            throw new IllegalStateException("failed to get generated user id");
        }
        return key.longValue();
    }
}

