package org.cloumon.gruter.common;

import javax.annotation.Resource;

import com.ibatis.sqlmap.client.SqlMapClient;

public abstract class SqlMapBase {
	@Resource(name="sqlMapClient")
	protected SqlMapClient sqlMapClient;

	public SqlMapClient getSqlMapClient() {
		return sqlMapClient;
	}

}
