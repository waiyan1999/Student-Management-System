package com.finalproject.Final.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PaymentDTO {

    private int enrollmentId;
    private int userId;
    private int amount;

    private String paymentMethod;
    private String paymentType;

    private int courseId;
}