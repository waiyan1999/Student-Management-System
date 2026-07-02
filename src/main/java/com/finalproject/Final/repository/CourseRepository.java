package com.finalproject.Final.repository;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.stereotype.Repository;

import com.finalproject.Final.model.CourseBean;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;

@Repository
public class CourseRepository {

    @Autowired
    private JdbcTemplate jdbc;
    
    @Autowired
    private NamedParameterJdbcTemplate namedParameterJdbcTemplate;

    private final CourseRowMapper mapper = new CourseRowMapper();

    // 🔹 GET ALL COURSES
    public List<CourseBean> findAll() {

    	 String sql =
    		        "SELECT c.*, " +
    		        "sc.name AS subcategory_name, " +
    		        "cc.name AS category_name, " +
    		        "u.name AS teacher_name " +
    		        "FROM course c " +
    		        "JOIN subcategory sc ON c.subCategory_id = sc.id " +
    		        "JOIN course_category cc ON sc.course_category_id = cc.id " +
    		        "JOIN user u ON c.teacher_id = u.id " +
    		        "WHERE u.role_id = 2";
    	

        return jdbc.query(sql, mapper);
    }

    // 🔹 GET BY ID
    public CourseBean findById(int id) {

    	String sql =
    	        "SELECT c.*, " +
    	        "cc.name AS category_name, " +
    	        "sc.name AS subcategory_name, " +
    	        "u.name AS teacher_name " +
    	        "FROM course c " +
    	        "JOIN course_category cc ON c.course_category_id = cc.id " +
    	        "JOIN subcategory sc ON c.subCategory_id = sc.id " +
    	        "JOIN user u ON c.teacher_id = u.id " +
    	        "WHERE c.id = ?";
      

        return jdbc.queryForObject(sql, mapper, id);
    }

    // 🔹 SAVE
    public void save(CourseBean c) {

        String sql =
            "INSERT INTO course (" +
            "course_category_id, teacher_id, name, description, duration, " +
            "fee, level, status, subcategory_id, " +
            "seats_total, seats_available, created_at, updated_at" +
            ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";

        jdbc.update(sql,

            c.getCourseCategoryId(),
            c.getTeacherId(),
            c.getName(),
            c.getDescription(),
            c.getDuration(),
            c.getFee(),
            c.getLevel(),
            c.getStatus(),
            c.getSubcategoryId(),

            c.getSeatsTotal(),

            // New course starts with all seats available
            //admin only hv to enter seats total
            c.getSeatsTotal()
        );
    }

    // 🔹 UPDATE
    public void update(CourseBean c) {

        String sql =
            "UPDATE course SET " +
            "course_category_id=?, " +
            "teacher_id=?, " +
            "name=?, " +
            "description=?, " +
            "duration=?, " +
            "fee=?, " +
            "level=?, " +
            "status=?, " +
            "subcategory_id=?, " +
            "seats_total=?, " +
            "seats_available=?, " +
            "updated_at=NOW() " +
            "WHERE id=?";

        jdbc.update(sql,

            c.getCourseCategoryId(),
            c.getTeacherId(),
            c.getName(),
            c.getDescription(),
            c.getDuration(),
            c.getFee(),
            c.getLevel(),
            c.getStatus(),
            c.getSubcategoryId(),

            c.getSeatsTotal(),
            c.getSeatsAvailable(),

            c.getId()
        );
    }
    
    public int getSeatsAvailable(int courseId) {

        String sql = "SELECT seats_available FROM course WHERE id = ?";
        return jdbc.queryForObject(sql, Integer.class, courseId);
    }
    
    public void decreaseSeat(int courseId) {
        jdbc.update(
            "UPDATE course SET seats_available = seats_available - 1 WHERE id = ? AND seats_available > 0",
            courseId
        );
    }

    // 🔹 DELETE
    public void delete(int id) {
        jdbc.update("DELETE FROM course WHERE id=?", id);
    }
    
    
    public List<CourseBean> getCoursesByIds(List<Integer> ids) {

        if (ids == null || ids.isEmpty()) {
            return new ArrayList<>();
        }

        String sql = "SELECT *\r\n"
        		+ "        FROM course\r\n"
        		+ "        WHERE id IN (:ids)";
            

        MapSqlParameterSource params = new MapSqlParameterSource();
        params.addValue("ids", ids);

        return namedParameterJdbcTemplate.query(sql, params, new CourseRowMapper());
    }
}