namespace Events
{
	class GearChange : Event
	{
		int m_prev;
		int m_new;

		string Text() override
		{
			return Icons::Cog + " " + tostring(m_new);
		}

		Json::Value@ ToJson() override
		{
			auto data = Event::ToJson();
			data['gear'] = Json::Object();
			data['gear']['prev'] = m_prev;
			data['gear']['new'] = m_new;
			return data;
		}

		vec4 Color() override
		{
			if (m_new > m_prev) {
				return vec4(0.5f, 1, 0.5f, 1);
			} else {
				return vec4(1, 0.5f, 0.5f, 1);
			}
		}
	}
}
