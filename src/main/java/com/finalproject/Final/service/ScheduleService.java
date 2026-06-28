package com.finalproject.Final.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.finalproject.Final.model.ScheduleBean;
import com.finalproject.Final.repository.ScheduleRepository;

@Service
public class ScheduleService {

    @Autowired
    private ScheduleRepository scheduleRepository;

    public List<ScheduleBean> getByCourseId(int courseId) {

        return scheduleRepository.findByCourseId(courseId);

    }

}