package org.cloumon.gruter.oozie.service.timer;

import java.util.List;

public interface JobRunner {
	public List<ScheduledJob> getScheduledJobs();
	public void runScheduledJob(ScheduledJob eachJob);
}
