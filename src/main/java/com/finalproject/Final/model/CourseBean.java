package com.finalproject.Final.model;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CourseBean {

    private int id;

    private int courseCategoryId;
    private int subCategoryId;

    private String name;
    private String description;

    private int duration;
    private int fee;

    private String level;
    private String status;

    private int createdBy;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private String filePath;
}