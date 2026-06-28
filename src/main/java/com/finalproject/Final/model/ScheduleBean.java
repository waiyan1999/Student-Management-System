package com.finalproject.Final.model;

import java.time.LocalDate;
import java.time.LocalTime;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ScheduleBean {
	
	private int id;
	private int courseId;
	private LocalDate date;
	private LocalTime startTime;
	private LocalTime endTime;
	private String room;

}
