function ConverseHotelSearch(prompt: string, hotel_options_data: string, travel_context: string, messages: string[]) -> HotelSearchOptionsResponse {
  client GPT4o
  prompt #"

    {{ _.role('system') }}
    {{ prompt }}

    {{ _.role('system') }}
    Travel context:
    {{ travel_context }}
    
    {% set user_string = "user" %}
    {% set assistant_string = "assistant" %}

    {% for m in messages %}
      {% if m[:user_string|length] == user_string %}
        {% set new_m = m[user_string|length:] %}
        {{ _.role(user_string) }}
        {{ new_m }}
      {% elif m[:assistant_string|length] == assistant_string %}
        {% set new_m = m[assistant_string|length:] %}
        {{ _.role(assistant_string) }}
        {{ new_m }}
      {% endif %}
    {% endfor %}

    {{ _.role('system') }}
    Hotel options:
    {{ hotel_options_data }}

    Extract the following data:
    {{ _.role('system') }}
    {{ ctx.output_format }}
    
  "#
}

class HotelSelectionReasons {

    // A JSON representation that characterizes why this hotel was selected to be one of the top six (6) options selected for the traveler.
    // Hotels should be chosen according to three (3) criteria:

    // - Primary: The traveler's hotel amenity and location preferences.
    // - Secondary: the traveler's hotel brand preferences.
    // - Tertiary: If there are no hotels that directly match location, amenity and brand preferences, then factor in the appeal of the hotel to a business traveler.

    choice_characteristic string @description(#" In only two words, articulate what makes this hotel unique and distinct from the other top chosen hotel options. "#)

    preference_alignment_reason string @description(#"
        - A sentence explaining how this hotel satisfies the traveler's hotel brand, location and amenity preferences and requests for this trip.  Include all preferences and requests that apply to this hotel.
        - The preference alignment reason should only include preferences or requests that you are confident can be satisfied by the hotel.
        - If a hotel cannot satisfy any of the traveler's preferences or requests, then say simply say that there are no specific preference or request alignments.

        Examples: "A Marriott close to downtown", "A Hyatt near the convention center", "A Hilton with a pool and free parking", "A Hilton close to the business district with good walkability", "A charming historical treasure near the art museum and great restaurants", "An upscale hotel with a chic barand restaurant and close to the airport", "Near active nightlife", "Upscale and quiet with a 24-hour gym", "A Kimpton with cheap rates", "Modern and stylish", "A Sheraton in a quiet area with a great bar and a pool", "Walking distance to central park, close to shppoing and the theater district.", "No specific match with your preferences", etc.
    "#)

    distinction_reason_one string @description(#"What's the primary characteristic that makes this hotel distinct and desireable from the other top chosen hotel options. These should be distinct from preference alignment reasons. "#)
    distinction_reason_two string @description(#"What's the secondary characteristic that makes this hotel distinct and desireable from the other top chosen hotel options. These should be distinct from preference alignment reasons. "#)
}

class HotelOptionSchema {

      /// A JSON representation of a single hotel selection (1 of 4), chosen from a larger set based on the traveler's preferences.

    hotel_name string @description(#"The full name of the hotel option."#)
    selection_reason HotelSelectionReasons
    hotel_class string @description(#"The class of the hotel (number of stars)."#)
    overall_rating string @description(#"The overall rating of the hotel."#)
    nearby_places string @description(#"The full list of names of nearby places."#)
    description string @description(#"The description provided for the hotel option."#)
    gps_coordinates string @description(#" 'latitude' and 'longitude' coordinates of the hotel option."#)
    amenities string[] @description(#"The full list of amenities for this property."#)
    check_in_time string @description(#"The check-in time for this property"#)
    check_out_time string @description(#"The check-out time for this property"#)
    image_url string @description(#"The image URL for this property."#)
    property_id int @description(#"The unique ID for this property."#)

}

class HotelSearchOptionsResponse {

      /// A JSON representation of six (6) hotels that are best aligned with the traveler's hotel brand, location and amenity preferences and requests.
      ///  Choose at least 4 hotel options.

    presentation_message string @description(#"A few sentences that provide a high-level overview of how the selected hotels align with the traveler's hotel brand, location and amenity preferences and requests.
        - If you can't find hotels that map to specific user preferences or requests, mention them in a separate sentence.
        - Always encourage the traveler to ask questions about the presented options."#)
    error_response string @description(#"Error - No hotel options were returned", description="If an error occurred, this should be the same message as the presentation message, prepended with 'An error occurred - '. "#)
    hotel_options HotelOptionSchema[] @description(#"a list of no more than six (6) hotel options, 'None' if no hotel options are available"#)
}

test hotel_search_test {
  functions [ConverseHotelSearch]
  args {
    prompt "\n\n    Role: Travel Hotel Options Selection Agent\n\n    Goal:  Choose the best six (6) hotel options from a list of many available hotels.\n\n    Background:\n        - You are a knowledgeable and helpful travel agent working in an agency that helps business travelers research and select hotels for their upcoming business trips.\n        - You have a keen sense of what hotel options will best match the business traveler's profile, preferences and requests.\n\n    Process:\n        - The options you select should align with the traveler's hotel brand, location and amenity preferences that appeal to business travelers.\n        - Choose six (6) hotels from the larger list of available hotels according to three (3) criteria, Primary, Secondary, and Tertiary:\n            - Primary: The traveler's hotel amenity and location preferences.\n            - Secondary: The traveler's hotel brand preferences.\n            - Tertiary: If there are no hotels that directly match location, amenity and brand preferences, then factor in the appeal of the hotel to a business traveler.\n        - Do not mention the exact number of hotel options you have chosen as this number may change by another downstream process.\n\n        - if the list of available hotels is empty then:\n            - Do not make up or imagine hotels\n            - Provide an error response back to the traveler in a friendly tone that no hotel options were returned and that they could try changing their search criteria or try again later. Store this message in the error_response key.\n"
    hotel_options_data "Hilton Garden Inn New York - Times Square Central \nProperty ID: 617929 \nOffering a restaurant and a fitness center, Hilton Garden Inn New York - Times Square Central is located in New York. Free WiFi is available.  Each room offers a flat-screen TV, refrigerator, microwave, coffee maker and alarm clock. All rooms feature private bathrooms with a shower, hairdryer and free toiletries.  At Hilton Garden Inn New York - Times Square Central, a 24-hour front desk and a lobby bar. A business center is also available.  The hotel is 656 ft from Times Square, 1.1 mi from Central Park and 328 ft from Broadway. Newark Airport is 11 mi away. \n136 West 42nd Street \nNew York City \nNY 10036 \nLat/Long: 40.75522, -73.985715 \nDistricts: Manhattan, Midtown, Broadway Theater District, Times Square, Central New York City \nReview score: 7.6 \nStars: 3.0 \nCheck in time: 15:00:00 \nCheck out time: 12:00:00 \nFacilities: Business center, Ironing facilities, ATM on site, Wake-up service, Bar, Parking, Fax/Photocopying, Restaurant, Fitness center, Safe, Free Wifi, Parking garage, Breakfast in the room, Tea/Coffee maker, Meeting/Banquet facilities, Contactless check-in/out, Air conditioning, Ironing service, Special diet meals (on request), Dry cleaning, Desk \nDistance: 0.09 \n\nCourtyard New York Manhattan/Times Square \nProperty ID: 265386 \nThis hotel is located in the heart of New York’s Fashion District, just a 3-minute walk from Times Square. It offers free Wi-Fi, a modern gym and café.  The modern rooms at Courtyard New York Manhattan/Times Square include a flat-screen cable TV with HBO and an iPod docking station. There is also a tea/coffee maker, safe and work desk.  The Courtyard New York Manhattan/Times Square offers the nosh! Cafe, where guests can enjoy a large American breakfast consisting of sweet and savory dishes. A 24-hour Market is also on site.  Guests can work out at the well-equipped gym, which includes cardiovascular equipment and free weights.  The hotel is 0.5 miles from the Empire State Building. It is also 8 miles from New York/La Guardia (LGA) Airport and offers an airport shuttle for a fee. \n114 West 40th Street \nNew York City \nNY 10018 \nLat/Long: 40.754001, -73.986562 \nDistricts: Manhattan, Midtown, Garment District, Times Square, Central New York City \nReview score: 8.2 \nStars: 3.0 \nCheck in time: 15:00:00 \nCheck out time: 12:00:00 \nFacilities: Business center, Ironing facilities, ATM on site, Wake-up service, Bar, Parking, Fax/Photocopying, Soundproof rooms, Express check-in/out, Restaurant, Fitness center, Safe, Free Wifi, Flat-screen TV, Upper floors accessible by elevator, Coffee machine, Entire unit wheelchair accessible, Parking garage, Tea/Coffee maker, Coffee house on site, Meeting/Banquet facilities, Contactless check-in/out, Air conditioning, Ironing service, Special diet meals (on request), Dry cleaning, Desk, Accessible parking, Concierge \nDistance: 0.15 \n\nHilton Garden Inn New York Times Square North \nProperty ID: 617915 \nHilton Garden Inn New York Times Square North offers accommodations in New York. The hotel has a terrace and fitness center, and guests can enjoy a meal at the restaurant.  Hilton Garden Inn New York Times Square North offers free WiFi and over 600 square feet of meeting space for small events. All guest rooms in the hotels are smoke free. You will find a 24-hour front desk at the property.  The on-site restaurant is open for breakfast, lunch and dinner.  Guests can walk to a Broadway show, tour the Empire State Building or visit Rockefeller Center, Top of the Rock, Carnegie Hall and Grand Central Station. The nearest airport is La Guardia Airport, 5.6 mi from the property. \n30 West 46th Street \nNew York City \nNY 10036 \nLat/Long: 40.756473, -73.98063 \nDistricts: Manhattan, Midtown, Times Square, Central New York City \nReview score: 7.7 \nStars: 3.0 \nCheck in time: 15:00:00 \nCheck out time: 12:00:00 \nFacilities: Restaurant, Fitness center, Business center, Ironing facilities, Internet facilities, Safe, Free Wifi, Flat-screen TV, Ironing service, Dry cleaning, Wake-up service, Bar, Parking, Fax/Photocopying, Meeting/Banquet facilities, Tea/Coffee maker, Desk, Air conditioning \nDistance: 0.21 \n\nCourtyard by Marriott New York Manhattan/ Fifth Avenue \nProperty ID: 262828 \nCourtyard Manhattan is a 30 floor-high building with a prestigious location on Fifth Avenue near New York City's Fashion District. It features rooms with panoramic city views and a well-equipped gym. A Starbucks can be found 1056 feet from the property.  Each room at the Courtyard New York Manhattan/Fifth Avenue is decorated with modern furnishings and includes a work desk. The rooms vary between 145 square feet to 203 square feet in size.  Dining options are a just a short walk from the hotel.  Courtyard Fifth Avenue is located less than a mile away from Times Square and half a mile from Grand Central Station. The Empire State Building and Broadway are both within a 5-minute walk away. \n3 East 40th Street \nNew York City \nNY 10016 \nLat/Long: 40.752022, -73.981144 \nDistricts: Manhattan, Midtown, Fifth Avenue, Central New York City \nReview score: 7.9 \nStars: 4.0 \nCheck in time: 16:00:00 \nCheck out time: 11:00:00 \nFacilities: Business center, Ironing facilities, Wake-up service, Fax/Photocopying, Parking, Express check-in/out, Fitness center, Safe, Free Wifi, Flat-screen TV, Upper floors accessible by elevator, Coffee machine, Parking garage, Car rental, Tea/Coffee maker, Coffee house on site, Valet parking, Air conditioning, Wake-up service/Alarm clock, Ironing service, Dry cleaning, Desk, Accessible parking, Currency exchange, Concierge \nDistance: 0.25 \n\nNew York Marriott Marquis \nProperty ID: 25294 \nLocated at Times Square and in the Theater District, this midtown Manhattan hotel offers complimentary WiFi and onsite dining options. Radio City Music Hall and Rockefeller Center is 2641 feet from New York Marriott Marquis.  The rooms at New York Marriott Marquis feature Marriott’s signature bedding, marble bathrooms, flat-screen TVs with Netflix app, iPod clock radios, phones, coffee and tea facilities, safe and iron with ironing boards.  New York Marriott Marquis has meeting space, a Broadway Ballroom with 29,000 square feet, three restaurants, lounge offering panoramic views of Times Square and two terraces. Amenities like a concierge lounge, cloakroom, a safe, a cash machine, WiFi and onsite shops including a souvenir shop are available for guests’ convenience.  NBC Studios is 2641 feet from New York Marriott Marquis. Central Park and Madison Square Garden are 0.7 mi away, while Carnegie Hall is 3169 feet away. Lincoln Center Plaza and United Nations Headquarters are 1.1 mi from the property. \n1535 Broadway \nNew York City \nNY 10036 \nLat/Long: 40.758375, -73.985559 \nDistricts: Manhattan, Midtown, Broadway Theater District, Times Square, Central New York City \nReview score: 8.3 \nStars: 5.0 \nCheck in time: 16:00:00 \nCheck out time: 11:00:00 \nFacilities: Business center, Ironing facilities, ATM on site, Wake-up service, Bar, Parking, Fax/Photocopying, Express check-in/out, Restaurant, Fitness center, Safe, Flat-screen TV, Upper floors accessible by elevator, Parking on site, Entire unit wheelchair accessible, Parking garage, Breakfast in the room, Executive lounge access, Coffee house on site, Valet parking, Meeting/Banquet facilities, Private Parking, Air conditioning, Terrace, Wake-up service/Alarm clock, Dry cleaning, Desk, Currency exchange, Concierge \nDistance: 0.25 \n\n"
    travel_context "{\"base_travel_preferences\":{\"preferred_home_airport\":\"SEA\",\"preferred_airline_brands\":[\"Delta Air Lines\"],\"preferred_cabin\":[\"Economy\"],\"preferred_seats\":null,\"preferred_hotel_brands\":[\"Marriott\",\"Hilton\"],\"preferred_travel_misc\":[\"Non-stop flights\",\"Central hotel locations\"]},\"trip_destination\":\"New York City\",\"trip_purpose\":null,\"trip_start_date\":\"2024-11-18\",\"trip_end_date\":\"2024-11-21\",\"hotel_location_preference\":\"Midtown\",\"preferred_flight_cancellation_policy\":\"non-refundable\",\"preferred_airlines\":[\"Delta Air Lines\"],\"preferred_outbound_departure_time\":null,\"preferred_return_departure_time\":null}"
    messages [
      "assistant I'll start planning a new trip for you. Please tell me where you are going and your travel dates. ",
      "user book hotel in NYC midtown nov 18-21",
      "assistant {\"hotel_task_classification\":\"Initiating a search\",\"task_classification_explanation\":\"The traveler has provided all the necessary information for a hotel search: destination city, check-in and check-out dates, preferred location, and implicit preferences.\",\"agent_response\":\"I\'ll initiate a search for hotels in Midtown, New York City, from November 18th to 21st, considering your preference for Marriott and Hilton brands.\",\"city\":\"New York City, NY\",\"location_neighborhoods_districts_landmarks\":\"Midtown\",\"location_latitude_longitude\":\"40.754932, -73.984016\",\"check_in_date\":\"2024-11-18\",\"check_out_date\":\"2024-11-21\",\"general_hotel_preferences\":[],\"brand_hotel_preferences\":[\"Marriott\",\"Hilton\"],\"trip_specific_hotel_amenity_preferences\":[],\"question_type\":null,\"gathered_required_information_for_hotel_search\":true,\"traveler_updated_search_criteria\":false,\"do_hotel_booking\":false,\"hotel_selection\":\"NONE\",\"property_id\":0,\"room_product_id\":\"NONE\",\"room_title\":\"NONE\",\"traveler_approved_hotel_booking\":false}"
    ]
  }
}
