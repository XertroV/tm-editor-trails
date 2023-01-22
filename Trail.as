class Trail
{
	array<Sample> m_samples;
	array<Event@> m_events;

	TrailPlayer@ m_player; //TODO: Do we need this here? It's a circular reference!

	vec3 m_lastPosition;
	int m_lastGear = 1;

	Trail()
	{
		m_samples.Reserve(1000);
		m_events.Reserve(25);

		@m_player = TrailPlayer(this);
	}

	void Update(CSmScriptPlayer@ scriptPlayer)
	{
		UpdateSample(scriptPlayer);
		UpdateEvents(scriptPlayer);
	}

	void UpdateSample(CSmScriptPlayer@ scriptPlayer)
	{
		// There is no reason to save a sample if we're still in the same position as the last time
		if (m_samples.Length > 0) {
			//TODO: We should also check vehicle rotation when we do this
			if ((m_lastPosition - scriptPlayer.Position).LengthSquared() < 0.1) {
				return;
			}
		}

		// Remember our last position
		m_lastPosition = scriptPlayer.Position;

		// Create a sample and store it in the trail
		Sample newSample;
		newSample.m_time = scriptPlayer.CurrentRaceTime / 1000.0;
		newSample.m_position = scriptPlayer.Position;
		newSample.m_dir = quat(scriptPlayer.AimDirection);
		newSample.m_velocity = scriptPlayer.Velocity;
		m_samples.InsertLast(newSample);
	}

	void UpdateEvents(CSmScriptPlayer@ scriptPlayer)
	{
		// If our gear changed
		int gear = scriptPlayer.EngineCurGear;
		if (m_lastGear != gear) {
			// Create a gear change event
			auto newGearChangeEvent = Events::GearChange();
			newGearChangeEvent.m_time = scriptPlayer.CurrentRaceTime / 1000.0;
			newGearChangeEvent.m_position = scriptPlayer.Position;
			newGearChangeEvent.m_prev = m_lastGear;
			newGearChangeEvent.m_new = gear;
			m_events.InsertLast(newGearChangeEvent);

			// Remember our last gear
			m_lastGear = scriptPlayer.EngineCurGear;
		}
	}

	double GetStartTime()
	{
		if (m_samples.Length == 0) {
			return 0;
		}
		return m_samples[0].m_time;
	}

	double GetEndTime()
	{
		// Subtract the last sample time with the first sample time to get the duration of the trail
		if (m_samples.Length == 0) {
			return 0;
		}
		return m_samples[m_samples.Length - 1].m_time;
	}

	double GetDuration()
	{
		// Subtract the last sample time with the first sample time to get the duration of the trail
		if (m_samples.Length == 0) {
			return 0;
		}
		double firstTime = m_samples[0].m_time;
		double lastTime = m_samples[m_samples.Length - 1].m_time;
		return lastTime - firstTime;
	}
}
