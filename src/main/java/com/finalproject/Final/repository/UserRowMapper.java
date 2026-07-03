package com.finalproject.Final.repository;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.jdbc.core.RowMapper;

import com.finalproject.Final.model.UserBean;

public class UserRowMapper implements RowMapper<UserBean> {

    @Override
    public UserBean mapRow(ResultSet rs, int rowNum) throws SQLException {

        UserBean u = new UserBean();

        u.setId(rs.getInt("id"));
        u.setRoleId(rs.getInt("role_id"));

        u.setName(rs.getString("name"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));

        u.setPhoneNumber(rs.getString("phone_no"));
        u.setAddress(rs.getString("address"));

        u.setDob(rs.getDate("dob") != null ? rs.getDate("dob").toLocalDate() : null);
        u.setGender(rs.getString("gender"));

        u.setCreatedAt(rs.getTimestamp("created_at") != null
                ? rs.getTimestamp("created_at").toLocalDateTime()
                : null);

        u.setIsActive(rs.getInt("is_active"));
        u.setFilePath(rs.getString("file_path"));

        return u;
    }
}