package org.cloumon.gruter.oozie.service.timer;

import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicLong;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class JobTimer extends Thread {
	private static final Logger LOG = LoggerFactory.getLogger(JobTimer.class);
	
	private static AtomicBoolean alreadyStarted = new AtomicBoolean(false);
	
	private AtomicBoolean stop = new AtomicBoolean(false);
	private JobRunner jobRunner;
	
	public JobTimer(JobRunner jobRunner) {
		this.jobRunner = jobRunner;
	}
	
	public void callStop() {
		stop.set(true);
		this.interrupt();
	}
	
	@Override
	public void run() {
		synchronized(alreadyStarted) {
			if(alreadyStarted.get()) {
				LOG.warn("==================>Scheduler timer already started");
				return;
			}
			alreadyStarted.set(true);
		}
		//initial sleep
		try {
			Thread.sleep(30 * 1000);
		} catch (InterruptedException e1) {
		}
		
		final AtomicLong currentTime = new AtomicLong(System.currentTimeMillis());
		long nextMinute = ((currentTime.get() / 60000) + 1) * 60000;
		
		LOG.info("==>Job Scheduler Timer started");
		while(!stop.get()) {
			long sleepTime = (nextMinute - System.currentTimeMillis());
			if (sleepTime > 0) {
				try {
					sleepDuration(sleepTime);
				} catch (InterruptedException e) {
					break;
				}
			}
			currentTime.set(System.currentTimeMillis());
			final List<ScheduledJob> jobs = jobRunner.getScheduledJobs();
			Thread t = new Thread() {
				public void run() {
					long time = currentTime.get();
					for(ScheduledJob eachJob: jobs) {
						try {
							CronPattern pattern = new CronPattern(eachJob.getScheduleInfo());
							if(pattern == null) {
								LOG.warn("No pattern info:" + eachJob.getJobName());
								continue;
							}
							
							if(pattern.match(time)) {
								LOG.info("LaunchJob: " + eachJob.getJobName());
								jobRunner.runScheduledJob(eachJob);
							}
						} catch (Exception e) {
							LOG.warn(e.getMessage(), e);
						}
					}
				}
			};
			t.start();
			nextMinute = ((currentTime.get() / 60000) + 1) * 60000;
		}
	}
	
	private void sleepDuration(long duration) throws InterruptedException {
		long sum = 0;
		do {
			long before = System.currentTimeMillis();
			sleep(duration - sum);
			long after = System.currentTimeMillis();
			sum += (after - before);
		} while (sum < duration);
	}
}
