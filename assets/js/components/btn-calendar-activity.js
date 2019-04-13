import { u } from 'umbrellajs';

u(document).on('click', '.btn-calendar-activity', function(event) {
  const date = u(event.currentTarget).data('date');
  u('#activity-modal .date').attr('value', date);
  $('#activity-modal').modal('show');
});
