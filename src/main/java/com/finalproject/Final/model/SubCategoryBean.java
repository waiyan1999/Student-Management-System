package com.finalproject.Final.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SubCategoryBean {

    private int id;
    private String name;
    private String description;

    private int courseCategoryId;
}