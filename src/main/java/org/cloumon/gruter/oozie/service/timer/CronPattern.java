package org.cloumon.gruter.oozie.service.timer;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.StringTokenizer;
import java.util.TimeZone;

public class CronPattern {
	private String pattern;
	private List<Integer> minutes = new ArrayList<Integer>();
	private List<Integer> hours = new ArrayList<Integer>();
	private List<Integer> dayOfMonths = new ArrayList<Integer>();
	private List<Integer> months = new ArrayList<Integer>();
	private List<Integer> weeks = new ArrayList<Integer>();
	
	public CronPattern(String pattern) throws Exception {
		this.pattern = pattern;
		//String[] tokens = pattern.split(" \t");
		StringTokenizer st = new StringTokenizer(pattern, " \t");
		if(st.countTokens() != 5) {
			throw new Exception("Wrong pattern[" + pattern + "]");
		}
		
		minutes = parsePattern("minute", st.nextToken(), 0, 59);
		hours = parsePattern("hour", st.nextToken(), 0, 23);	
		dayOfMonths = parsePattern("monthOfDay", st.nextToken(), 1, 31);	
		months = parsePattern("month", st.nextToken(), 1, 12);	
		weeks = parsePattern("week", st.nextToken(), 0, 6);	
	}
	
	public String getPattern() {
		return pattern;
	}
	
	private List<Integer> parsePattern(String name, String pattern, int min, int max) throws Exception {
		String[] tokens = pattern.split("/");
		if(tokens.length > 2) {
			throw new Exception("Wrong " + name + " pattern[" + pattern + "]");
		}
		List<Integer> times = getTimeRange(tokens[0], min, max);
		
		if(tokens.length == 1) {
			return times;
		} else if(tokens.length == 2) {
			int gap = Integer.parseInt(tokens[1]);
			int size = times.size();

			List<Integer> result = new ArrayList<Integer>();
			
			for(int i = 0; i < size; i+= gap) {
				if(!result.contains(times.get(i))) {
					result.add(times.get(i));
				}
			}
			
			return result;
		} else {
			throw new Exception("Wrong " + name + " pattern[" + pattern + "]");
		}
	}
	
	private List<Integer> getTimeRange(String pattern, int min, int max) throws Exception {
		List<Integer> result = new ArrayList<Integer>();
		if("*".equals(pattern)) {
			for(int i = min; i <= max; i++) {
				result.add(i);
			}
			
			return result;
		}
		
		String[] commaTokens = pattern.split(",");
		for(String eachToken: commaTokens) {
			String[] tokens = eachToken.split("-");
			if(tokens.length == 1) {
				int value = Integer.parseInt(tokens[0]);
				if(value < min || value > max) {
					throw new Exception("value[" + value + " out of range [" + min + " ~ " + max + "]"); 
				}
				result.add(value);
			} else {
				int valueMin = Integer.parseInt(tokens[0]);
				int valueMax = Integer.parseInt(tokens[1]);
				if(valueMin < min || valueMax > max) {
					throw new Exception("value[" + pattern + " out of range [" + min + " ~ " + max + "]"); 
				}
				for(int i = valueMin; i <= valueMax; i++) {
					result.add(i);
				}
			}
		}
		
		return result;
	}
	
	public boolean match(long time) {
		return match(TimeZone.getDefault(), time);
	}

	public boolean match(TimeZone timezone, long time) {
		Calendar calendar = Calendar.getInstance(timezone);
		calendar.setTimeInMillis(time);
		
		int minute = calendar.get(Calendar.MINUTE);
		int hour = calendar.get(Calendar.HOUR_OF_DAY);
		int dayOfMonth = calendar.get(Calendar.DAY_OF_MONTH);
		int month = calendar.get(Calendar.MONTH) + 1;
		int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK) - 1;

		return match(minutes, minute) && match(hours, hour) && match(dayOfMonths, dayOfMonth) &&
				match(months, month) && match(weeks, dayOfWeek);
	}
	
	private boolean match(List<Integer> data, int value) {
		for(int eachValue: data) {
			if(eachValue == value) {
				return true;
			}
		}
		
		return false;
	}

	public static void main(String[] args) throws Exception {
		CronPattern pattern = new CronPattern("* */21 * 2-3 *");
		System.out.println(">>>>>>>" + pattern.match(System.currentTimeMillis()));
	}
}
