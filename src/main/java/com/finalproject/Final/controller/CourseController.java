package com.finalproject.Final.Controller;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;


import com.finalproject.Final.service.CourseService;


@Controller
@RequestMapping("/courses")
public class CourseController {

    @Autowired
    private CourseService courseService;

    @GetMapping("/show")
    public String showCourses(Model model) {

        model.addAttribute("courses", courseService.getAllCourses());

        return "courses";
    }

    @GetMapping("/{id}")
    public String courseDetail(@PathVariable int id, Model model) {

        model.addAttribute("course", courseService.getById(id));

        return "course-detail";
    }
}
