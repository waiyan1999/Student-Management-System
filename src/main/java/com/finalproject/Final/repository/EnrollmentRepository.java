package com.finalproject.Final.repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class EnrollmentRepository {

    @Autowired
    private JdbcTemplate jdbc;

    public int save(int userId, int courseId, LocalDate date) {

        String sql = " INSERT INTO enrollment\r\n"
        		+ "            (user_id, course_id, enrollment_date, status, created_at, updated_at)\r\n"
        		+ "            VALUES (?, ?, ?, ?, NOW(), NOW())";

        jdbc.update(sql, userId, courseId, date, 0);

        return jdbc.queryForObject("SELECT LAST_INSERT_ID()", Integer.class);
    }

    public Map<String, Object> findById(int id) {

        return jdbc.queryForMap(
            "SELECT * FROM enrollment WHERE id = ?",
            id
        );
    }

    public List<Map<String, Object>> findByUser(int userId) {

        String sql = "SELECT e.*, c.title AS course_title\r\n"
        		+ "            FROM enrollment e\r\n"
        		+ "            JOIN course c ON e.course_id = c.id\r\n"
        		+ "            WHERE e.user_id = ?";

        return jdbc.queryForList(sql, userId);
    }

    public void updateStatus(int enrollmentId, int status) {

        jdbc.update(
            "UPDATE enrollment SET status=?, updated_at=NOW() WHERE id=?",
            status,
            enrollmentId
        );
    }
}
