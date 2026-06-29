package com.finalproject.Final.advice;

import com.finalproject.Final.model.CourseCategoryBean;
import com.finalproject.Final.service.CourseCategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import java.util.List;

@ControllerAdvice
public class GlobalModelAdvice {

    @Autowired
    private CourseCategoryService categoryService;

    @ModelAttribute("allCategories")
    public List<CourseCategoryBean> getAllCategories() {
        return categoryService.getAllCourseCategory();
    }
}