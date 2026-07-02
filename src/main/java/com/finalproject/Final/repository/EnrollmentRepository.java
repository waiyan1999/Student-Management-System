package com.finalproject.Final.repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.finalproject.Final.model.CourseBean;
import com.finalproject.Final.model.EnrollmentBean;

@Repository
public class EnrollmentRepository {

    @Autowired
    private JdbcTemplate jdbc;

    public int save(int userId, int courseId, LocalDate date) {

        String sql = " INSERT INTO enrollment\r\n"
        		+ "            (user_id, course_id, enrollment_date, status, created_at, updated_at)\r\n"
        		+ "            VALUES (?, ?, ?, 0, NOW(), NOW())";

        jdbc.update(sql, userId, courseId, date);

        return jdbc.queryForObject("SELECT LAST_INSERT_ID()", Integer.class);
    }

    public EnrollmentBean findById(int id) {

        String sql = "SELECT * FROM enrollment WHERE id = ?";

        return jdbc.queryForObject(sql, new EnrollmentRowMapper(), id);
    }

    public List<EnrollmentBean> findByUser(int userId) {

        String sql =
            "SELECT e.*, c.name AS course_title " +
            "FROM enrollment e " +
            "JOIN course c ON e.course_id = c.id " +
            "WHERE e.user_id = ?";

        return jdbc.query(sql, new EnrollmentRowMapper(), userId);
    }

    public void updateStatus(int enrollmentId, int status) {

        jdbc.update(
            "UPDATE enrollment SET status=?, updated_at=NOW() WHERE id=?",
            status,
            enrollmentId
        );
    }
    
    
    public boolean existsByUserIdAndCourseId(int userId, int courseId) {

        String sql = " SELECT COUNT(*) \r\n"
        		+ "        FROM enrollment \r\n"
        		+ "        WHERE user_id = ? AND course_id = ?";

        Integer count = jdbc.queryForObject(sql, Integer.class, userId, courseId);
        return count != null && count > 0;
    }
    
    
    public List<CourseBean> getEnrolledCourses(int userId) {

        String sql = " SELECT\r\n"
        		+ "        c.id,\r\n"
        		+ "        c.name,\r\n"
        		+ "        c.description,\r\n"
        		+ "        c.duration,\r\n"
        		+ "        c.fee,\r\n"
        		+ "        c.level,\r\n"
        		+ "        c.status,\r\n"
        		+ "        c.course_category_id,\r\n"
        		+ "        c.teacher_id,\r\n"
        		+ "        c.SubCategory_id AS subcategory_id,\r\n"
        		+ "        c.seats_total,\r\n"
        		+ "        c.seats_available,\r\n"
        		+ "\r\n"
        		+ "        cat.name AS category_name,\r\n"
        		+ "        sub.name AS subcategory_name,\r\n"
        		+ "        u.name AS teacher_name\r\n"
        		+ "\r\n"
        		+ "    FROM enrollment e\r\n"
        		+ "    JOIN course c ON e.course_id = c.id\r\n"
        		+ "    LEFT JOIN course_category cat ON c.course_category_id = cat.id\r\n"
        		+ "    LEFT JOIN subcategory sub ON c.SubCategory_id = sub.id\r\n"
        		+ "    LEFT JOIN `user` u ON c.teacher_id = u.id\r\n"
        		+ "\r\n"
        		+ "    WHERE e.user_id = ?\r\n"
        		+ "      AND e.status = 1";
            
       

        return jdbc.query(sql, new CourseRowMapper(), userId);
    }

}
    
    // Get all enrolled courses for a user
//    public List<CourseBean> getEnrolledCourses(int userId) {
//
//        String sql = "SELECT c.*\r\n"
//        		+ "        FROM enrollment e\r\n"
//        		+ "        JOIN course c ON e.course_id = c.id\r\n"
//        		+ "        WHERE e.user_id = ?";
//
//        return jdbc.query(sql, new CourseRowMapper(), userId);
//    }
    
    
//    public List<CourseBean> getEnrolledCourses(int userId) {
//
//        String sql = "SELECT *\r\n"
//        		+ "        FROM course\r\n"
//        		+ "        WHERE id IN (\r\n"
//        		+ "            SELECT course_id\r\n"
//        		+ "            FROM enrollment\r\n"
//        		+ "            WHERE user_id = ?\r\n"
//        		+ "        )";
//
//        return jdbc.query(sql, new CourseRowMapper(), userId);
    


