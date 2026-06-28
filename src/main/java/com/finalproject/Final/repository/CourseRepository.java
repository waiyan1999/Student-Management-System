package com.finalproject.Final.repository;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.finalproject.Final.model.CourseBean;

@Repository
public class CourseRepository {

    @Autowired
    private JdbcTemplate jdbc;

    private final CourseRowMapper mapper = new CourseRowMapper();

    // 🔹 GET ALL COURSES
    public List<CourseBean> findAll() {

    	String sql =
    		    "SELECT c.*, " +
    		    "sc.name AS subcategory_name, " +
    		    "cc.name AS category_name " +
    		    "FROM course c " +
    		    "JOIN subcategory sc ON c.subcategory_id = sc.id " +
    		    "JOIN course_category cc ON sc.course_category_id = cc.id";

        return jdbc.query(sql, mapper);
    }

    // 🔹 GET BY ID
    public CourseBean findById(int id) {

        String sql =
            "SELECT c.*, " +
            "sc.name AS subcategory_name, " +
            "cc.name AS category_name " +
            "FROM course c " +
            "JOIN subcategory sc ON c.subcategory_id = sc.id " +
            "JOIN course_category cc ON sc.course_category_id = cc.id " +
            "WHERE c.id = ?";

        return jdbc.queryForObject(sql, mapper, id);
    }

    // 🔹 SAVE
    public void save(CourseBean c) {

        String sql =
            "INSERT INTO course (title, description, subcategory_id, created_at, updated_at) " +
            "VALUES (?, ?, ?, NOW(), NOW())";

        jdbc.update(sql,
            c.getName(),
            c.getDescription(),
            c.getSubcategoryId()
        );
    }

    // 🔹 UPDATE
    public void update(CourseBean c) {

        String sql =
            "UPDATE course SET title=?, description=?, subcategory_id=?, updated_at=NOW() WHERE id=?";

        jdbc.update(sql,
        		c.getName(),
            c.getDescription(),
            c.getSubcategoryId(),
            c.getId()
        );
    }

    // 🔹 DELETE
    public void delete(int id) {
        jdbc.update("DELETE FROM course WHERE id=?", id);
    }
}