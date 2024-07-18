require 'tzinfo'
require 'date'

p TZInfo::Timezone.all_identifiers

tz = TZInfo::Timezone.get('Europe/London')
dt = DateTime.parse('2023-03-27 11:35:59.123456')
p dt
p tz.local_time(dt).utc
p tz.local_time(2023, 3, 26, 11, 35, 0).utc