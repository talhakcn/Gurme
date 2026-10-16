import 'package:gurme_client/src/model/anonymous_feedback.dart';
import 'package:gurme_client/src/model/autocomplete_response.dart';
import 'package:gurme_client/src/model/autocomplete_suggestion.dart';
import 'package:gurme_client/src/model/checkin_input.dart';
import 'package:gurme_client/src/model/error_response.dart';
import 'package:gurme_client/src/model/feedback_write_response.dart';
import 'package:gurme_client/src/model/geo_point.dart';
import 'package:gurme_client/src/model/gurme_list.dart';
import 'package:gurme_client/src/model/gurme_list_created.dart';
import 'package:gurme_client/src/model/gurme_list_input.dart';
import 'package:gurme_client/src/model/gurme_list_item.dart';
import 'package:gurme_client/src/model/gurme_list_update.dart';
import 'package:gurme_client/src/model/health_status.dart';
import 'package:gurme_client/src/model/insights_request.dart';
import 'package:gurme_client/src/model/insights_response.dart';
import 'package:gurme_client/src/model/place_features.dart';
import 'package:gurme_client/src/model/place_insight.dart';
import 'package:gurme_client/src/model/quota_exceeded_response.dart';
import 'package:gurme_client/src/model/quota_status.dart';
import 'package:gurme_client/src/model/search_filters.dart';
import 'package:gurme_client/src/model/search_request.dart';
import 'package:gurme_client/src/model/search_response.dart';
import 'package:gurme_client/src/model/stored_checkin.dart';
import 'package:gurme_client/src/model/venue.dart';
import 'package:gurme_client/src/model/venue_reaction_input.dart';
import 'package:gurme_client/src/model/venue_report_input.dart';
import 'package:gurme_client/src/model/venue_report_response.dart';
import 'package:gurme_client/src/model/venue_report_review_input.dart';
import 'package:gurme_client/src/model/venue_report_review_queue.dart';
import 'package:gurme_client/src/model/venue_report_review_queue_item.dart';
import 'package:gurme_client/src/model/venue_report_review_queue_item_reports_inner.dart';
import 'package:gurme_client/src/model/venue_report_review_response.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

ReturnType deserialize<ReturnType, BaseType>(
  dynamic value,
  String targetType, {
  bool growable = true,
}) {
  switch (targetType) {
    case 'String':
      return '$value' as ReturnType;
    case 'int':
      return (value is int ? value : int.parse('$value')) as ReturnType;
    case 'bool':
      if (value is bool) {
        return value as ReturnType;
      }
      final valueString = '$value'.toLowerCase();
      return (valueString == 'true' || valueString == '1') as ReturnType;
    case 'double':
      return (value is double ? value : double.parse('$value')) as ReturnType;
    case 'AnonymousFeedback':
      return AnonymousFeedback.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AutocompleteResponse':
      return AutocompleteResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AutocompleteSuggestion':
      return AutocompleteSuggestion.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CheckinInput':
      return CheckinInput.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ErrorResponse':
      return ErrorResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FeedbackWriteResponse':
      return FeedbackWriteResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FilterStatus':
    case 'GeoPoint':
      return GeoPoint.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'GurmeList':
      return GurmeList.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'GurmeListCreated':
      return GurmeListCreated.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GurmeListInput':
      return GurmeListInput.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GurmeListItem':
      return GurmeListItem.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GurmeListUpdate':
      return GurmeListUpdate.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GurmeListVisibility':
    case 'HealthStatus':
      return HealthStatus.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'InsightsRequest':
      return InsightsRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'InsightsResponse':
      return InsightsResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PlaceFeatures':
      return PlaceFeatures.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PlaceInsight':
      return PlaceInsight.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'QuotaExceededResponse':
      return QuotaExceededResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'QuotaStatus':
      return QuotaStatus.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ReactionType':
    case 'SearchFilters':
      return SearchFilters.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SearchRequest':
      return SearchRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SearchResponse':
      return SearchResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Signal':
    case 'StoredCheckin':
      return StoredCheckin.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Venue':
      return Venue.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'VenueCategory':
    case 'VenueReactionInput':
      return VenueReactionInput.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VenueReportInput':
      return VenueReportInput.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VenueReportResponse':
      return VenueReportResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VenueReportReviewInput':
      return VenueReportReviewInput.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VenueReportReviewQueue':
      return VenueReportReviewQueue.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VenueReportReviewQueueItem':
      return VenueReportReviewQueueItem.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VenueReportReviewQueueItemReportsInner':
      return VenueReportReviewQueueItemReportsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'VenueReportReviewResponse':
      return VenueReportReviewResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VenueReportStatus':
    case 'VenueReportType':
    default:
      RegExpMatch? match;

      if (value is List && (match = _regList.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toList(growable: growable)
            as ReturnType;
      }
      if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toSet()
            as ReturnType;
      }
      if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
        targetType = match![1]!.trim(); // ignore: parameter_assignments
        return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map(
                (dynamic v) => deserialize<BaseType, BaseType>(
                  v,
                  targetType,
                  growable: growable,
                ),
              ),
            )
            as ReturnType;
      }
      break;
  }
  throw Exception('Cannot deserialize');
}
