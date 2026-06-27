package com.finalproject.Final.service;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.finalproject.Final.repository.EnrollmentRepository;

@Service
public class EnrollmentService {

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    public int createEnrollment(int userId, int courseId) {

        return enrollmentRepository.save(
                userId,
                courseId,
                LocalDate.now()
        );
    }

    public Map<String, Object> getById(int id) {
        return enrollmentRepository.findById(id);
    }

    public List<Map<String, Object>> getByUser(int userId) {
        return enrollmentRepository.findByUser(userId);
    }

    public void markAsPaid(int enrollmentId) {
        enrollmentRepository.updateStatus(enrollmentId, 1);
    }
}
