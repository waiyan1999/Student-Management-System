package com.finalproject.Final.repository;

import java.time.LocalDate;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class PaymentRepository {

    @Autowired
    private JdbcTemplate jdbc;

    // Save payment (main payment table)
    public int savePayment(int amount,
                           String paymentMethod,
                           String paymentStatus,
                           int courseId) {

        String sql = "INSERT INTO payment\r\n"
        		+ "            (amount, payment_date, payment_method, payment_status,\r\n"
        		+ "             created_at, updated_at, course_id)\r\n"
        		+ "            VALUES (?, ?, ?, ?, NOW(), NOW(), ?)";
        
        jdbc.update(sql,
                amount,
                LocalDate.now(),
                paymentMethod,
                paymentStatus,
                courseId
        );

        return jdbc.queryForObject("SELECT LAST_INSERT_ID()", Integer.class);
    }

    //  Save payment record (link user ↔ payment)
    public void savePaymentRecord(int paymentId,
                                  int userId,
                                  String paymentType) {

        String sql = "INSERT INTO payment_record\r\n"
        		+ "            (payment_id, user_id, payment_type)\r\n"
        		+ "            VALUES (?, ?, ?)";

        jdbc.update(sql, paymentId, userId, paymentType);
    }

    // Get payment by enrollment
    public Map<String, Object> getPaymentByEnrollment(int enrollmentId) {

        String sql = "SELECT p.*\r\n"
        		+ "            FROM payment p\r\n"
        		+ "            JOIN enrollment e ON p.course_id = e.course_id\r\n"
        		+ "            WHERE e.id = ?";

        return jdbc.queryForMap(sql, enrollmentId);
    }
}