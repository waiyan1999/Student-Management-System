package com.finalproject.Final.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import com.finalproject.Final.model.CourseBean;
import com.finalproject.Final.model.ScheduleBean;
import com.finalproject.Final.service.CourseService;
import com.finalproject.Final.service.ScheduleService;

@Controller
@RequestMapping("/courses")
public class CourseController {

    @Autowired
    private CourseService courseService;

    @Autowired
    private ScheduleService scheduleService;

    // Show all courses
    @GetMapping("/show")
    public String showCourses(Model model) {
        model.addAttribute("courses", courseService.getAllCourses());
        return "student/courses";
    }

    // Show course detail page
    @GetMapping("/{id}")
    public String showCourseDetail(@PathVariable int id, Model model) {

        CourseBean course = courseService.getById(id);
        List<ScheduleBean> schedules = scheduleService.getByCourseId(id);
        
        if (course.getSeatsAvailable() == 0) {
            course.setStatus("FULL");
        }

        model.addAttribute("course", course);
        model.addAttribute("schedules", schedules);

        return "student/course-detail";
    }
}