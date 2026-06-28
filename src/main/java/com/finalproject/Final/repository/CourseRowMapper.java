package com.finalproject.Final.repository;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.jdbc.core.RowMapper;

import com.finalproject.Final.model.CourseBean;

public class CourseRowMapper implements RowMapper<CourseBean> {

    @Override
    public CourseBean mapRow(ResultSet rs, int rowNum) throws SQLException {

        CourseBean c = new CourseBean();

        c.setId(rs.getInt("id"));
        c.setName(rs.getString("name"));
        c.setDescription(rs.getString("description"));
        
        c.setDuration(rs.getString("duration"));
        c.setFee(rs.getInt("fee"));
        c.setLevel(rs.getString("level"));

        // MUST match column name in SQL
        c.setSubcategoryId(rs.getInt("subcategory_id"));

        // from JOIN (must exist in SQL alias)
        c.setSubcategoryName(rs.getString("subcategory_name"));
        c.setCategoryName(rs.getString("category_name"));

        return c;
    }
}