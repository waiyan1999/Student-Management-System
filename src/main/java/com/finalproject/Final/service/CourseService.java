package com.finalproject.Final.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.finalproject.Final.model.CourseBean;
import com.finalproject.Final.repository.CourseRepository;

@Service
public class CourseService {

    @Autowired
    private CourseRepository courseRepository;

    public List<CourseBean> getAllCourses() {
        return courseRepository.findAll();
    }

    public CourseBean getById(int id) {
        return courseRepository.findById(id);
    }

    public void createCourse(CourseBean c) {
        courseRepository.save(c);
    }

    public void updateCourse(CourseBean c) {
        courseRepository.update(c);
    }

    public void deleteCourse(int id) {
        courseRepository.delete(id);
    }
}