package com.finalproject.Final.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class EnrollmentBean {

	private int id;
	private int userId;
	private int courseId;
	private LocalDate enrollDate;
	private int status;
	private LocalDateTime createdAt;
	private LocalDateTime updatedAt;

}
