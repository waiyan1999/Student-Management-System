package com.finalproject.Final.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.finalproject.Final.model.UserBean;

@Repository
public class UserRepository {

    @Autowired
    private JdbcTemplate jdbc;

    private final UserRowMapper mapper = new UserRowMapper();
    
    public UserBean findByEmail(String email) {
        String sql = "SELECT * FROM user WHERE email = ?";
        try {
            return jdbc.queryForObject(
                    sql,
                    new BeanPropertyRowMapper<>(UserBean.class),
                    email);
        } catch (Exception e) {
            return null;
        }
    }
    
    
    public int updatePassword(String email, String newPassword) {
        String sql = "UPDATE user SET password = ? WHERE email = ?";
        return jdbc.update(sql, newPassword, email);
    }

    // GET USER BY ID
    public UserBean findById(int id) {

        String sql = "SELECT * FROM user WHERE id = ?";

        return jdbc.queryForObject(sql, mapper, id);
    }

    // OPTIONAL: GET TEACHERS ONLY
    public UserBean findTeacherById(int id) {

        String sql = "SELECT * FROM user WHERE id = ? AND role_id = 2";

        return jdbc.queryForObject(sql, mapper, id);
    }
    
    
    
}