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
        c.setCourseCategoryId(rs.getInt("course_category_id"));
        c.setTeacherId(rs.getInt("teacher_id"));
        c.setName(rs.getString("name"));
        c.setDescription(rs.getString("description"));
        
        c.setDuration(rs.getString("duration"));
        c.setFee(rs.getInt("fee"));
        c.setLevel(rs.getString("level"));
        c.setStatus(rs.getString("status"));


        // MUST match column name in SQL
        c.setSubcategoryId(rs.getInt("subcategory_id"));
        //seats
        c.setSeatsTotal(rs.getInt("seats_total"));
        c.setSeatsAvailable(rs.getInt("seats_available"));

        // from JOIN (must exist in SQL alias)
        c.setSubcategoryName(rs.getString("subcategory_name"));
        c.setCategoryName(rs.getString("category_name"));
        c.setTeacherName(rs.getString("teacher_name"));
        
      
        
       

        return c;
    }
}