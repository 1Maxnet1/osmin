#ifndef TRACKER_H
#define TRACKER_H

#include "csvparser.h"

#include <osmscout/VehiclePosition.h>
#include <osmscout/RouteStep.h>
#include <osmscout/gpx/TrackPoint.h>
#include <osmscout/gpx/Waypoint.h>

#include <QObject>
#include <QDateTime>
#include <QThread>
#include <QTimer>
#include <QSharedPointer>
#include <QDir>
#include <QFile>
#include <QMutex>

class TrackerModule;

class Tracker : public QObject
{
  Q_OBJECT

  Q_PROPERTY(QObject* trackerPosition READ getTrackerPosition NOTIFY trackerPositionChanged)
  Q_PROPERTY(double elevation READ getElevation NOTIFY trackerDataChanged)
  Q_PROPERTY(double currentSpeed READ getCurrentSpeed NOTIFY trackerDataChanged)
  Q_PROPERTY(double distance READ getDistance NOTIFY trackerDataChanged)
  Q_PROPERTY(double duration READ getDuration NOTIFY trackerDataChanged)
  Q_PROPERTY(double ascent READ getAscent NOTIFY trackerDataChanged)
  Q_PROPERTY(double descent READ getDescent NOTIFY trackerDataChanged)
  Q_PROPERTY(double maxSpeed READ getMaxSpeed NOTIFY trackerDataChanged)
  Q_PROPERTY(double lat READ getLat NOTIFY trackerPositionChanged)
  Q_PROPERTY(double lon READ getLon NOTIFY trackerPositionChanged)
  Q_PROPERTY(QString recording READ getRecording WRITE setRecording NOTIFY trackerRecordingChanged)
  Q_PROPERTY(bool processing READ getProcessing NOTIFY trackerProcessingChanged)
  Q_PROPERTY(bool isRecording READ getIsRecording NOTIFY trackerRecordingChanged)
  Q_PROPERTY(int markCount READ getMarkCount NOTIFY trackerPositionMarked)
  //Q_PROPERTY(double remainingDistance READ getRemainingDistance NOTIFY remainingDistanceChanged)
  //Q_PROPERTY(QObject* nextRouteStep READ getNextRoutStep NOTIFY nextStepChanged)

public:
  Tracker(QObject* parent = nullptr);
  virtual ~Tracker();

  bool init(const QString& root);

  osmscout::VehiclePosition* getTrackerPosition() const;

  double getElevation() const { return m_elevation; }
  double getCurrentSpeed() const { return m_currentSpeed; }
  double getDistance() const { return m_distance; }
  double getDuration() const { return m_duration; }
  double getAscent() const { return m_ascent; }
  double getDescent() const { return m_descent; }
  double getMaxSpeed() const { return m_maxSpeed.value; }
  double getLat() const { return m_vehicleCoord.GetLat(); }
  double getLon() const { return m_vehicleCoord.GetLon(); }
  QString getRecording() const { return m_recording; }
  void setRecording(const QString& filename);
  bool getProcessing() const { return m_busy; }
  bool getIsRecording() const;
  int getMarkCount() const;

  Q_INVOKABLE void locationChanged(bool positionValid, double lat, double lon,
                                   bool horizontalAccuracyValid, double horizontalAccuracy,
                                   double alt = 0.0);
  Q_INVOKABLE void azimuthChanged(double azimuth);
  Q_INVOKABLE void reset();
  Q_INVOKABLE void startRecording();
  Q_INVOKABLE void resumeRecording(const QString& filename);
  Q_INVOKABLE void stopRecording();
  Q_INVOKABLE void pinPosition();
  Q_INVOKABLE void markPosition(const QString& symbol, const QString& name, const QString& description);

signals:
  void trackerPositionChanged();
  void trackerDataChanged();
  void trackerRecordingChanged();
  void trackerProcessingChanged();
  void trackerPositionRecorded(double lat, double lon);
  void trackerPositionMarked(double lat, double lon, const QString& symbol, const QString& name);
  void recordingFailed();
  //void remainingDistanceChanged();
  //void nextStepChanged();

  void locationUpdate(bool positionValid, double lat, double lon, double alt);
  void azimuthUpdate(double degrees);
  void doReset();
  void doStartRecording();
  void doResumeRecording(const QString& filename);
  void doStopRecording();

private slots:
  void onPositionChanged(const osmscout::PositionAgent::PositionState state,
                         const osmscout::GeoCoord coord,
                         const std::optional<osmscout::Bearing> bearing);
  void onDataChanged(double kmph, double meters, double seconds, double ascent, double descent);
  void onRecordingChanged(const QString& filename);
  void onProcessingChanged(bool busy);
  void onPositionRecorded(const osmscout::GeoCoord coord);

private:
  TrackerModule* m_p;

  osmscout::Vehicle m_vehicle;
  osmscout::PositionAgent::PositionState m_vehicleState;
  osmscout::GeoCoord m_vehicleCoord;
  std::optional<osmscout::Bearing> m_vehicleBearing;
  double m_elevation;
  double m_currentSpeed;
  double m_distance;
  double m_duration;
  double m_ascent;
  double m_descent;
  struct {
    double seconds;
    double meters;
    double value;
  } m_maxSpeed;
  bool m_busy;
  QString m_recording;
  //std::vector<osmscout::RouteStep> m_routeSteps;
  //osmscout::RouteStep m_nextRouteStep;
  //osmscout::Distance m_remainingDistance;
};

class TrackerModule : public QObject
{
  Q_OBJECT
public:
  TrackerModule(QThread* thread, const QString& root);
  virtual ~TrackerModule();

  void record();
  bool isRecording() const { return m_recording; }

  int getMarkCount() const { return m_markCount; }
  void pinPosition();
  osmscout::GeoCoord markPosition(const QString& symbol, const QString& name, const QString& description);

signals:
  void dataChanged(double kmph, double distance, double duration, double ascent, double descent);
  void positionChanged(const osmscout::PositionAgent::PositionState state,
                       const osmscout::GeoCoord coord,
                       const std::optional<osmscout::Bearing> bearing);
  void recordingFailed();
  void recordingChanged(const QString& filename);
  void processing(bool busy);
  void positionRecorded(const osmscout::GeoCoord coord);

public slots:
  void onTimeout();
  void onLocationChanged(bool positionValid, double lat, double lon, double alt);
  void onAzimuthChanged(double degrees);
  void onReset();
  void onStartRecording();
  void onResumeRecording(const QString& filename);
  void onStopRecording();
  void onFlushRecording();

private:
  QThread* m_t;
  QDir m_baseDir;
  QTimer m_timer;
  osmscout::PositionAgent::PositionState m_state;
  double m_azimuth;
  double m_currentSpeed;
  typedef struct {
    osmscout::Timestamp time;
    osmscout::GeoCoord coord;
    osmscout::Bearing bearing;
    double elevation;
    inline operator bool() const { return time.time_since_epoch() != osmscout::Timestamp::duration::zero(); }
  } position_t;
  position_t m_lastPosition;
  QScopedPointer<position_t> m_pinnedPosition;
  struct {
    osmscout::Timestamp time;
    osmscout::GeoCoord coord;
    osmscout::Bearing bearing;
    inline operator bool() const { return time.time_since_epoch() != osmscout::Timestamp::duration::zero(); }
  } m_lastRecord;

  double m_distance;
  double m_duration;
  double m_ascent;
  double m_descent;

  bool m_recording;
  int m_markCount;
  QList<osmscout::gpx::TrackPoint> m_segment;
  QMutex m_lock;
  QSharedPointer<QFile> m_file;
  osmin::CSVParser* m_formater;
  QScopedPointer<osmscout::gpx::Waypoint> m_mark;
};

#endif // TRACKER_H
