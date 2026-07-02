package com.finalproject.Final.service;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.finalproject.Final.dto.EnrollmentDTO;
import com.finalproject.Final.model.CourseBean;
import com.finalproject.Final.model.EnrollmentBean;
import com.finalproject.Final.repository.CourseRepository;
import com.finalproject.Final.repository.EnrollmentRepository;

@Service
public class EnrollmentService {

    @Autowired
    private EnrollmentRepository repo;
    
    @Autowired
    private CourseRepository courseRepo;

    public int createEnrollment(EnrollmentDTO dto) {

        // prevent duplicate enrollment
        if (repo.existsByUserIdAndCourseId(dto.getUserId(), dto.getCourseId())) {
            throw new RuntimeException("Already enrolled in this course");
        }

        return repo.save(dto.getUserId(), dto.getCourseId(), LocalDate.now());
    }

    public EnrollmentBean getById(int id) {
        return repo.findById(id);
    }
    
   
    
    public List<EnrollmentBean> getByUser(int userId) {
        return repo.findByUser(userId);
    }

    public void confirmEnrollment(int enrollmentId) {
        repo.updateStatus(enrollmentId, 1);
    }
    
    public List<CourseBean> getEnrolledCourses(int userId) {
        return repo.getEnrolledCourses(userId);
    }
    
//    public List<CourseBean> getEnrolledCourses(int userId) {
//
//        List<Integer> courseIds = repo.getEnrolledCourseIds(userId);
//
//        return courseRepo.getCoursesByIds(courseIds);
//    }
    

}