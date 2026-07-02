package com.finalproject.Final.util;

public class UserCodeUtil {

    public static String formatUserCode(int roleId, int id) {

        return switch (roleId) {

            case 1 -> String.format("AD%04d", id);

            case 2 -> String.format("T%04d", id);

            case 3 -> String.format("ST%04d", id);

            default -> String.valueOf(id);
        };
    }
}