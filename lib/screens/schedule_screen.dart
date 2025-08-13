import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule.dart';
import '../models/client.dart';
import '../models/package.dart';
import '../models/exercise.dart';
import '../services/data_service.dart';
import 'add_course_record_screen.dart';
import '../widgets/course_detail_modal.dart';

enum ScheduleViewType { day, threeDay, week, month }

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  ScheduleViewType _viewType = ScheduleViewType.threeDay;
  List<Schedule> _schedules = [];

  @override
  void initState() {
    super.initState();
    // 移除测试数据，使用实时数据
  }

  void _addTestSchedules() {
    // 移除测试数据方法
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20), // 增加顶部间距
            // 标题区域
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const Text(
                    '课程排程',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '安排客户课程时间',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // 本月课程统计
            StreamBuilder<List<Schedule>>(
              stream: Provider.of<DataService>(
                context,
                listen: false,
              ).streamSchedules(),
              builder: (context, snapshot) {
                int totalThisMonth = 0;
                if (snapshot.hasData) {
                  final now = DateTime.now();
                  final startOfMonth = DateTime(now.year, now.month, 1);
                  final endOfMonth = DateTime(now.year, now.month + 1, 0);

                  totalThisMonth = snapshot.data!.where((schedule) {
                    // 检查日期是否在本月范围内
                    final scheduleDate = DateTime(
                      schedule.date.year,
                      schedule.date.month,
                      schedule.date.day,
                    );
                    final isInThisMonth =
                        scheduleDate.isAfter(
                          startOfMonth.subtract(const Duration(days: 1)),
                        ) &&
                        scheduleDate.isBefore(endOfMonth);

                    if (!isInThisMonth) return false;

                    // 只统计已完成的课程（绿色卡片）
                    return schedule.status == ScheduleStatus.completed;
                  }).length;
                }

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '本月已完成课程: $totalThisMonth',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 主要内容区域
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // 视图控制区域
                    _buildViewControls(),

                    // 导航控制区域
                    _buildNavigationControls(),

                    // 时间表格区域
                    Expanded(
                      child: StreamBuilder<List<Schedule>>(
                        stream: Provider.of<DataService>(
                          context,
                          listen: false,
                        ).streamSchedules(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '加载课程数据失败',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '请检查网络连接或稍后重试',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF667eea),
                                ),
                              ),
                            );
                          }
                          _schedules = snapshot.data ?? [];
                          return _buildScheduleGrid();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 添加课程功能
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('添加课程功能开发中...'),
              backgroundColor: Color(0xFF667eea),
            ),
          );
        },
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildViewControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            _getViewTypeText(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              _buildViewButton('1天', ScheduleViewType.day),
              const SizedBox(width: 8),
              _buildViewButton('3天', ScheduleViewType.threeDay),
              const SizedBox(width: 8),
              _buildViewButton('周', ScheduleViewType.week),
              const SizedBox(width: 8),
              _buildViewButton('月', ScheduleViewType.month),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton(String text, ScheduleViewType type) {
    final isSelected = _viewType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _viewType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667eea) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF667eea) : Colors.grey,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildNavButton(_getPrevButtonText(), () {
            setState(() {
              _selectedDate = _getPrevDate();
            });
          }, false),
          const SizedBox(width: 8),
          _buildNavButton(_getCurrentButtonText(), () {
            setState(() {
              _selectedDate = _getCurrentDate();
            });
          }, true),
          const SizedBox(width: 8),
          _buildNavButton(_getNextButtonText(), () {
            setState(() {
              _selectedDate = _getNextDate();
            });
          }, false),
        ],
      ),
    );
  }

  String _getPrevButtonText() {
    switch (_viewType) {
      case ScheduleViewType.day:
        return '昨天';
      case ScheduleViewType.threeDay:
        return '前3天';
      case ScheduleViewType.week:
        return '上周';
      case ScheduleViewType.month:
        return '上月';
    }
  }

  String _getCurrentButtonText() {
    switch (_viewType) {
      case ScheduleViewType.day:
        return '今天';
      case ScheduleViewType.threeDay:
        return '今日';
      case ScheduleViewType.week:
        return '今周';
      case ScheduleViewType.month:
        return '今月';
    }
  }

  String _getNextButtonText() {
    switch (_viewType) {
      case ScheduleViewType.day:
        return '明天';
      case ScheduleViewType.threeDay:
        return '后3天';
      case ScheduleViewType.week:
        return '下周';
      case ScheduleViewType.month:
        return '下月';
    }
  }

  DateTime _getPrevDate() {
    switch (_viewType) {
      case ScheduleViewType.day:
        return _selectedDate.subtract(const Duration(days: 1));
      case ScheduleViewType.threeDay:
        return _selectedDate.subtract(const Duration(days: 3));
      case ScheduleViewType.week:
        return _selectedDate.subtract(const Duration(days: 7));
      case ScheduleViewType.month:
        return DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    }
  }

  DateTime _getCurrentDate() {
    switch (_viewType) {
      case ScheduleViewType.day:
      case ScheduleViewType.threeDay:
        return DateTime.now();
      case ScheduleViewType.week:
        return DateTime.now();
      case ScheduleViewType.month:
        return DateTime.now();
    }
  }

  DateTime _getNextDate() {
    switch (_viewType) {
      case ScheduleViewType.day:
        return _selectedDate.add(const Duration(days: 1));
      case ScheduleViewType.threeDay:
        return _selectedDate.add(const Duration(days: 3));
      case ScheduleViewType.week:
        return _selectedDate.add(const Duration(days: 7));
      case ScheduleViewType.month:
        return DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    }
  }

  Widget _buildNavButton(String text, VoidCallback onTap, bool isSelected) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667eea) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF667eea) : Colors.grey,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleGrid() {
    switch (_viewType) {
      case ScheduleViewType.day:
        return _buildDayView();
      case ScheduleViewType.threeDay:
        return _buildThreeDayView();
      case ScheduleViewType.week:
        return _buildWeekView();
      case ScheduleViewType.month:
        return _buildMonthView();
    }
  }

  Widget _buildDayView() {
    final date = _selectedDate;
    return _buildTimeGrid([date]);
  }

  Widget _buildThreeDayView() {
    final dates = [
      _selectedDate.subtract(const Duration(days: 1)),
      _selectedDate,
      _selectedDate.add(const Duration(days: 1)),
    ];
    return _buildTimeGrid(dates);
  }

  Widget _buildWeekView() {
    final dates = List.generate(7, (index) {
      final startOfWeek = _selectedDate.subtract(
        Duration(days: _selectedDate.weekday - 1),
      );
      return startOfWeek.add(Duration(days: index));
    });
    return _buildTimeGrid(dates);
  }

  Widget _buildMonthView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 日历网格
          _buildMonthCalendar(),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar() {
    final year = _selectedDate.year;
    final month = _selectedDate.month;

    // 获取月份的第一天和最后一天
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);

    // 获取月份第一天是星期几（1=周一，7=周日）
    final firstWeekday = firstDayOfMonth.weekday;

    // 计算需要显示的天数（包括上个月的部分天数和下个月的部分天数）
    final daysInMonth = lastDayOfMonth.day;
    final totalDays = 42; // 6周 * 7天

    // 计算上个月需要显示的天数
    final daysFromPrevMonth = firstWeekday - 1;

    return Column(
      children: [
        // 星期标题行
        Container(
          height: 40,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
          ),
          child: Row(
            children: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'].map((day) {
              return Expanded(
                child: Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  child: Text(
                    day,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // 日历网格
        Column(
          children: List.generate(6, (weekIndex) {
            return IntrinsicHeight(
              child: Row(
                children: List.generate(7, (dayIndex) {
                  final index = weekIndex * 7 + dayIndex;
                  final dayOffset = index - daysFromPrevMonth + 1;
                  DateTime date;

                  if (dayOffset <= 0) {
                    // 上个月的天数
                    final prevMonth = month == 1 ? 12 : month - 1;
                    final prevYear = month == 1 ? year - 1 : year;
                    final daysInPrevMonth = DateTime(
                      prevYear,
                      prevMonth + 1,
                      0,
                    ).day;
                    date = DateTime(
                      prevYear,
                      prevMonth,
                      daysInPrevMonth + dayOffset,
                    );
                  } else if (dayOffset > daysInMonth) {
                    // 下个月的天数
                    final nextMonth = month == 12 ? 1 : month + 1;
                    final nextYear = month == 12 ? year + 1 : year;
                    date = DateTime(
                      nextYear,
                      nextMonth,
                      dayOffset - daysInMonth,
                    );
                  } else {
                    // 当前月的天数
                    date = DateTime(year, month, dayOffset);
                  }

                  final isCurrentMonth = date.month == month;
                  final isToday =
                      date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;
                  final isSelected =
                      date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;

                  final schedules = _getSchedulesForDate(date);

                  return Expanded(
                    child: _buildMonthDayCell(
                      date: date,
                      isCurrentMonth: isCurrentMonth,
                      isToday: isToday,
                      isSelected: isSelected,
                      schedules: schedules,
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMonthDayCell({
    required DateTime date,
    required bool isCurrentMonth,
    required bool isToday,
    required bool isSelected,
    required List<Schedule> schedules,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667eea).withOpacity(0.2) : null,
          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期和事件数量
            Container(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${date.month}/${date.day}',
                      style: TextStyle(
                        color: isCurrentMonth
                            ? (isToday ? const Color(0xFF667eea) : Colors.white)
                            : Colors.grey.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (schedules.isNotEmpty)
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF667eea),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          schedules.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 事件列表
            if (schedules.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: schedules.map((schedule) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      '${schedule.startTime.split(':')[0]}:${schedule.startTime.split(':')[1]} ${schedule.clientName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  List<Schedule> _getSchedulesForDate(DateTime date) {
    return _schedules.where((schedule) {
      final scheduleDate = DateTime(
        schedule.date.year,
        schedule.date.month,
        schedule.date.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return scheduleDate == targetDate;
    }).toList();
  }

  Widget _buildTimeGrid(List<DateTime> dates) {
    final timeSlots = List.generate(19, (index) => index + 5); // 05:00 到 23:00

    return Column(
      children: [
        // 表头
        Container(
          height: 40,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
          ),
          child: Row(
            children: [
              // 时间列标题
              Container(
                width: 60,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: const Text(
                  '时间',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 日期列标题
              ...dates.map((date) {
                final isToday =
                    date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;
                return Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isToday
                          ? const Color(0xFF667eea).withOpacity(0.2)
                          : null,
                      border: const Border(
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getDayOfWeek(date.weekday),
                          style: TextStyle(
                            color: isToday
                                ? const Color(0xFF667eea)
                                : Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '${date.month}/${date.day}',
                          style: TextStyle(
                            color: isToday
                                ? const Color(0xFF667eea)
                                : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        // 时间表格
        Expanded(
          child: ListView.builder(
            itemCount: timeSlots.length,
            itemBuilder: (context, timeIndex) {
              final hour = timeSlots[timeIndex];
              return Container(
                height: 60,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    // 时间列
                    Container(
                      width: 60,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                      ),
                      child: Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // 日期列
                    ...dates.map((date) {
                      final schedules = _getSchedulesForTimeSlot(date, hour);
                      return Expanded(
                        child: GestureDetector(
                          onTapUp: (details) {
                            _handleTimeSlotTap(
                              date,
                              hour,
                              details.localPosition,
                            );
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: _buildTimeSlotContent(
                              date,
                              hour,
                              0,
                              schedules,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCell(Schedule schedule) {
    // 根据课程状态决定卡片颜色
    Color cardColor = Colors.white;
    if (schedule.status == ScheduleStatus.cancelled) {
      cardColor = Colors.yellow;
    } else if (schedule.status == ScheduleStatus.completed) {
      cardColor = Colors.green;
    }

    return GestureDetector(
      onTap: () => _showCourseDetailsDialog(schedule),
      child: Container(
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.all(2),
        height: double.infinity, // 确保卡片覆盖整个高度
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 垂直居中内容
          crossAxisAlignment: CrossAxisAlignment.center, // 水平居中内容
          children: [
            Text(
              schedule.clientName,
              style: TextStyle(
                color: schedule.status == ScheduleStatus.cancelled
                    ? Colors.black87
                    : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center, // 文字居中
            ),
            const SizedBox(height: 2),
            Text(
              '${schedule.startTime}-${schedule.endTime}',
              style: TextStyle(
                color: schedule.status == ScheduleStatus.cancelled
                    ? Colors.black54
                    : Colors.black54,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center, // 文字居中
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotContent(
    DateTime date,
    int hour,
    int minute,
    List<Schedule> schedules,
  ) {
    // 查找匹配的课程
    final matchingSchedule = schedules.where((schedule) {
      final timeParts = schedule.startTime.split(':');
      final startHour = int.parse(timeParts[0]);
      final startMinute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
      return startHour == hour && startMinute == minute;
    }).firstOrNull;

    if (matchingSchedule != null) {
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: _buildScheduleCell(matchingSchedule),
      );
    } else {
      // 空的时间槽，可以点击预约
      return Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(2),
        ),
        child: const SizedBox.expand(),
      );
    }
  }

  List<Schedule> _getSchedulesForTimeSlot(DateTime date, int hour) {
    return _schedules.where((schedule) {
      final scheduleDate = DateTime(
        schedule.date.year,
        schedule.date.month,
        schedule.date.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);

      if (scheduleDate != targetDate) return false;

      // 解析开始时间，支持半点
      final timeParts = schedule.startTime.split(':');
      final startHour = int.parse(timeParts[0]);
      final startMinute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

      return startHour == hour;
    }).toList();
  }

  void _handleTimeSlotTap(DateTime date, int hour, Offset localPosition) {
    // 所有课程都固定为一小时，不再区分整点和半点
    final startTime = DateTime(date.year, date.month, date.day, hour, 0);
    final endTime = startTime.add(const Duration(hours: 1));

    // 检查该时间段是否已被占用
    final existingSchedules = _getSchedulesForTimeSlot(date, hour);
    if (existingSchedules.isNotEmpty) {
      // 该时间段已被占用，显示提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('该时间段已被占用，无法预约新课程'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 显示预约课程对话框
    _showScheduleDialog(date, startTime, endTime);
  }

  void _showScheduleDialog(
    DateTime date,
    DateTime startTime,
    DateTime endTime,
  ) {
    final startTimeStr =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endTimeStr =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    String selectedClientId = '';
    String selectedClientName = '';
    String selectedPackageId = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Text(
              '预约课程',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '日期: ${date.year}/${date.month}/${date.day}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '时间: $startTimeStr - $endTimeStr',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '客户姓名 (选择或输入):',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 客户搜索和选择组合控件
                  StreamBuilder<List<Client>>(
                    stream: Provider.of<DataService>(
                      context,
                      listen: false,
                    ).streamClients(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text(
                          '加载客户数据失败',
                          style: TextStyle(color: Colors.red),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 50,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        );
                      }

                      final clients = snapshot.data ?? [];

                      return Autocomplete<Client>(
                        fieldViewBuilder:
                            (
                              context,
                              textEditingController,
                              focusNode,
                              onFieldSubmitted,
                            ) {
                              // 当selectedClientName改变时，更新controller
                              if (selectedClientName.isNotEmpty &&
                                  textEditingController.text !=
                                      selectedClientName) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  textEditingController.text =
                                      selectedClientName;
                                });
                              }

                              return TextField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: '输入客户姓名搜索...',
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF3A3A3A),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  suffixIcon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.grey,
                                  ),
                                ),
                                onChanged: (value) {
                                  // 当输入改变时，清除选中的客户和配套
                                  if (value.isEmpty ||
                                      !clients.any(
                                        (client) => client.name == value,
                                      )) {
                                    setDialogState(() {
                                      selectedClientId = '';
                                      selectedClientName = '';
                                      selectedPackageId = '';
                                    });
                                  }
                                },
                              );
                            },
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return clients;
                          }
                          return clients.where(
                            (client) => client.name.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            ),
                          );
                        },
                        displayStringForOption: (Client client) => client.name,
                        onSelected: (Client client) {
                          setDialogState(() {
                            selectedClientId = client.id;
                            selectedClientName = client.name;
                            selectedPackageId = ''; // 重置配套选择
                          });
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Material(
                            color: const Color(0xFF3A3A3A),
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final client = options.elementAt(index);
                                  return ListTile(
                                    title: Text(
                                      client.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Text(
                                      client.phone,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    onTap: () {
                                      onSelected(client);
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '选择配套:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 从配套集合中获取客户的有效配套
                  StreamBuilder<List<Package>>(
                    stream: selectedClientId.isNotEmpty
                        ? Provider.of<DataService>(
                            context,
                            listen: false,
                          ).streamPackages()
                        : Stream.value(<Package>[]),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text(
                          '加载配套数据失败',
                          style: TextStyle(color: Colors.red),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 50,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        );
                      }

                      final packages = snapshot.data ?? [];
                      final clientPackages = packages
                          .where(
                            (package) =>
                                package.clientId == selectedClientId &&
                                package.status == PackageStatus.active &&
                                package.remainingSessions > 0,
                          )
                          .toList();

                      // 如果没有配套，显示提示
                      if (selectedClientId.isNotEmpty &&
                          clientPackages.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A3A3A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '该客户暂无有效配套',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        value: selectedPackageId.isEmpty
                            ? null
                            : selectedPackageId,
                        decoration: InputDecoration(
                          hintText: '不使用配套',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF3A3A3A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          suffixIcon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey,
                          ),
                        ),
                        dropdownColor: const Color(0xFF3A3A3A),
                        style: const TextStyle(color: Colors.white),
                        items: [
                          const DropdownMenuItem<String>(
                            value: '',
                            child: Text(
                              '不使用配套',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          ...clientPackages.map((package) {
                            return DropdownMenuItem<String>(
                              value: package.id,
                              child: Text(
                                '配套${clientPackages.indexOf(package) + 1} - 剩余${package.remainingSessions}次',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          selectedPackageId = value ?? '';
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: selectedClientId.isEmpty
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        _confirmSchedule(
                          date,
                          startTimeStr,
                          endTimeStr,
                          selectedClientId,
                          selectedClientName,
                          selectedPackageId,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                ),
                child: const Text('确认预约'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmSchedule(
    DateTime date,
    String startTime,
    String endTime,
    String clientId,
    String clientName,
    String packageId,
  ) async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final newSchedule = Schedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientId: clientId,
      clientName: clientName,
      date: date,
      startTime: startTime,
      endTime: endTime,
      type: ScheduleType.personal,
      status: ScheduleStatus.confirmed,
      notes: '',
    );

    try {
      await dataService.addSchedule(newSchedule);

      // 如果选择了配套，扣减配套课时
      if (packageId.isNotEmpty) {
        final packages = await dataService.getPackages();
        final selectedPackage = packages.firstWhere(
          (package) => package.id == packageId,
        );
        if (selectedPackage.remainingSessions > 0) {
          final updatedPackage = selectedPackage.copyWith(
            remainingSessions: selectedPackage.remainingSessions - 1,
          );
          await dataService.updatePackage(updatedPackage);
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已为 $clientName 预约课程'),
            backgroundColor: const Color(0xFF667eea),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('预约失败，请重试'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getViewTypeText() {
    switch (_viewType) {
      case ScheduleViewType.day:
        return '1日视图';
      case ScheduleViewType.threeDay:
        return '3日视图';
      case ScheduleViewType.week:
        return '周视图';
      case ScheduleViewType.month:
        return '月视图';
    }
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return '周一';
      case 2:
        return '周二';
      case 3:
        return '周三';
      case 4:
        return '周四';
      case 5:
        return '周五';
      case 6:
        return '周六';
      case 7:
        return '周日';
      default:
        return '';
    }
  }

  Color _getScheduleTypeColor(ScheduleType type) {
    switch (type) {
      case ScheduleType.personal:
        return Colors.blue;
      case ScheduleType.group:
        return Colors.green;
      case ScheduleType.consultation:
        return Colors.orange;
    }
  }

  void _showCourseDetailsDialog(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => CourseDetailModal(
        schedule: schedule,
        onDelete: () => _showDeleteCourseDialog(schedule),
        onCancelCourse: () => _showCancelCourseDialog(schedule),
      ),
    );
  }

  String _getScheduleStatusText(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.confirmed:
        return '已确认';
      case ScheduleStatus.pending:
        return '待确认';
      case ScheduleStatus.cancelled:
        return '已取消';
      case ScheduleStatus.completed:
        return '已完成';
    }
  }

  Color _getScheduleStatusColor(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.confirmed:
        return Colors.green;
      case ScheduleStatus.pending:
        return Colors.orange;
      case ScheduleStatus.cancelled:
        return Colors.red;
      case ScheduleStatus.completed:
        return Colors.green;
    }
  }

  void _showDeleteCourseDialog(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          '删除课程',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '确定要删除 ${schedule.clientName} 的课程吗？',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // 关闭删除确认对话框
              Navigator.of(context).pop(); // 关闭课程详情对话框

              final dataService = Provider.of<DataService>(
                context,
                listen: false,
              );
              try {
                await dataService.deleteSchedule(schedule.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已删除 ${schedule.clientName} 的课程'),
                    backgroundColor: const Color(0xFF667eea),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('删除失败，请重试'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCancelCourseDialog(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          '确认取消课程',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '是否要扣减客户课时?\n选择"是"将扣减1次课时,\n选择"否"将保持课时不变。',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // 关闭取消确认对话框
              Navigator.of(context).pop(); // 关闭课程详情对话框

              // 不扣课时，直接删除课程
              final dataService = Provider.of<DataService>(
                context,
                listen: false,
              );
              try {
                await dataService.deleteSchedule(schedule.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已删除 ${schedule.clientName} 的课程'),
                    backgroundColor: const Color(0xFF667eea),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('删除失败，请重试'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('否 (不扣课时)', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // 关闭取消确认对话框
              Navigator.of(context).pop(); // 关闭课程详情对话框

              // 扣课时，将课程状态改为已取消，并扣减配套课时
              final dataService = Provider.of<DataService>(
                context,
                listen: false,
              );
              final updatedSchedule = schedule.copyWith(
                status: ScheduleStatus.cancelled,
              );

              try {
                await dataService.updateSchedule(updatedSchedule);

                // 查找并扣减配套课时
                final packages = await dataService.getPackages();
                final clientPackages = packages
                    .where(
                      (package) =>
                          package.clientId == schedule.clientId &&
                          package.status == PackageStatus.active &&
                          package.remainingSessions > 0,
                    )
                    .toList();

                if (clientPackages.isNotEmpty) {
                  // 扣减第一个有效配套的课时
                  final packageToUpdate = clientPackages.first;
                  final updatedPackage = packageToUpdate.copyWith(
                    remainingSessions: packageToUpdate.remainingSessions - 1,
                  );
                  await dataService.updatePackage(updatedPackage);
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已取消 ${schedule.clientName} 的课程并扣减1次课时'),
                    backgroundColor: const Color(0xFF667eea),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('取消失败，请重试'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('是 (扣课时)', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showNewRecordDialog(Schedule schedule) {
    Navigator.of(context).pop(); // 关闭课程详情对话框

    // 直接跳转到新建课程记录表单
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCourseRecordScreen(
          clientId: schedule.clientId,
          clientName: schedule.clientName,
          selectedDate: schedule.date,
        ),
      ),
    );
  }
}
