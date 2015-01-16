//
//  CountryTableViewController.swift
//  tapster
//
//  Created by Matthew Lewis on 14/01/2015.
//  Copyright (c) 2015 iD Foundry. All rights reserved.
//

import UIKit

class CountryTableViewController: UITableViewController {
    
    struct country {
        let code : String
        let name : String
    }

    var countries = [country (code:"AF", name:"Afghanistan"),  country (code:"AX", name:"Åland Islands"),  country (code:"AL", name:"Albania"),  country (code:"DZ", name:"Algeria"),  country (code:"AS", name:"American Samoa"),  country (code:"AD", name:"Andorra"),  country (code:"AO", name:"Angola"),  country (code:"AI", name:"Anguilla"),  country (code:"AQ", name:"Antarctica"),  country (code:"AG", name:"Antigua and Barbuda"),  country (code:"AR", name:"Argentina"),  country (code:"AM", name:"Armenia"),  country (code:"AW", name:"Aruba"),  country (code:"AU", name:"Australia"),  country (code:"AT", name:"Austria"),  country (code:"AZ", name:"Azerbaijan"),  country (code:"BS", name:"Bahamas"),  country (code:"BH", name:"Bahrain"),  country (code:"BD", name:"Bangladesh"),  country (code:"BB", name:"Barbados"),  country (code:"BY", name:"Belarus"),  country (code:"BE", name:"Belgium"),  country (code:"BZ", name:"Belize"),  country (code:"BJ", name:"Benin"),  country (code:"BM", name:"Bermuda"),  country (code:"BT", name:"Bhutan"),  country (code:"BO", name:"Bolivia, Plurinational State of"),  country (code:"BQ", name:"Bonaire, Sint Eustatius and Saba"),  country (code:"BA", name:"Bosnia and Herzegovina"),  country (code:"BW", name:"Botswana"),  country (code:"BV", name:"Bouvet Island"),  country (code:"BR", name:"Brazil"),  country (code:"IO", name:"British Indian Ocean Territory"),  country (code:"BN", name:"Brunei Darussalam"),  country (code:"BG", name:"Bulgaria"),  country (code:"BF", name:"Burkina Faso"),  country (code:"BI", name:"Burundi"),  country (code:"KH", name:"Cambodia"),  country (code:"CM", name:"Cameroon"),  country (code:"CA", name:"Canada"),  country (code:"CV", name:"Cape Verde"),  country (code:"KY", name:"Cayman Islands"),  country (code:"CF", name:"Central African Republic"),  country (code:"TD", name:"Chad"),  country (code:"CL", name:"Chile"),  country (code:"CN", name:"China"),  country (code:"CX", name:"Christmas Island"),  country (code:"CC", name:"Cocos (Keeling) Islands"),  country (code:"CO", name:"Colombia"),  country (code:"KM", name:"Comoros"),  country (code:"CG", name:"Congo"),  country (code:"CD", name:"Congo, the Democratic Republic of the"),  country (code:"CK", name:"Cook Islands"),  country (code:"CR", name:"Costa Rica"),  country (code:"CI", name:"Côte d'Ivoire"),  country (code:"HR", name:"Croatia"),  country (code:"CU", name:"Cuba"),  country (code:"CW", name:"Curaçao"),  country (code:"CY", name:"Cyprus"),  country (code:"CZ", name:"Czech Republic"),  country (code:"DK", name:"Denmark"),  country (code:"DJ", name:"Djibouti"),  country (code:"DM", name:"Dominica"),  country (code:"DO", name:"Dominican Republic"),  country (code:"EC", name:"Ecuador"),  country (code:"EG", name:"Egypt"),  country (code:"SV", name:"El Salvador"),  country (code:"GQ", name:"Equatorial Guinea"),  country (code:"ER", name:"Eritrea"),  country (code:"EE", name:"Estonia"),  country (code:"ET", name:"Ethiopia"),  country (code:"FK", name:"Falkland Islands (Malvinas)"),  country (code:"FO", name:"Faroe Islands"),  country (code:"FJ", name:"Fiji"),  country (code:"FI", name:"Finland"),  country (code:"FR", name:"France"),  country (code:"GF", name:"French Guiana"),  country (code:"PF", name:"French Polynesia"),  country (code:"TF", name:"French Southern Territories"),  country (code:"GA", name:"Gabon"),  country (code:"GM", name:"Gambia"),  country (code:"GE", name:"Georgia"),  country (code:"DE", name:"Germany"),  country (code:"GH", name:"Ghana"),  country (code:"GI", name:"Gibraltar"),  country (code:"GR", name:"Greece"),  country (code:"GL", name:"Greenland"),  country (code:"GD", name:"Grenada"),  country (code:"GP", name:"Guadeloupe"),  country (code:"GU", name:"Guam"),  country (code:"GT", name:"Guatemala"),  country (code:"GG", name:"Guernsey"),  country (code:"GN", name:"Guinea"),  country (code:"GW", name:"Guinea-Bissau"),  country (code:"GY", name:"Guyana"),  country (code:"HT", name:"Haiti"),  country (code:"HM", name:"Heard Island and McDonald Islands"),  country (code:"VA", name:"Holy See (Vatican City State)"),  country (code:"HN", name:"Honduras"),  country (code:"HK", name:"Hong Kong"),  country (code:"HU", name:"Hungary"),  country (code:"IS", name:"Iceland"),  country (code:"IN", name:"India"),  country (code:"ID", name:"Indonesia"),  country (code:"IR", name:"Iran, Islamic Republic of"),  country (code:"IQ", name:"Iraq"),  country (code:"IE", name:"Ireland"),  country (code:"IM", name:"Isle of Man"),  country (code:"IL", name:"Israel"),  country (code:"IT", name:"Italy"),  country (code:"JM", name:"Jamaica"),  country (code:"JP", name:"Japan"),  country (code:"JE", name:"Jersey"),  country (code:"JO", name:"Jordan"),  country (code:"KZ", name:"Kazakhstan"),  country (code:"KE", name:"Kenya"),  country (code:"KI", name:"Kiribati"),  country (code:"KP", name:"Korea, Democratic People's Republic of"),  country (code:"KR", name:"Korea, Republic of"),  country (code:"KW", name:"Kuwait"),  country (code:"KG", name:"Kyrgyzstan"),  country (code:"LA", name:"Lao People's Democratic Republic"),  country (code:"LV", name:"Latvia"),  country (code:"LB", name:"Lebanon"),  country (code:"LS", name:"Lesotho"),  country (code:"LR", name:"Liberia"),  country (code:"LY", name:"Libya"),  country (code:"LI", name:"Liechtenstein"),  country (code:"LT", name:"Lithuania"),  country (code:"LU", name:"Luxembourg"),  country (code:"MO", name:"Macao"),  country (code:"MK", name:"Macedonia, the former Yugoslav Republic of"),  country (code:"MG", name:"Madagascar"),  country (code:"MW", name:"Malawi"),  country (code:"MY", name:"Malaysia"),  country (code:"MV", name:"Maldives"),  country (code:"ML", name:"Mali"),  country (code:"MT", name:"Malta"),  country (code:"MH", name:"Marshall Islands"),  country (code:"MQ", name:"Martinique"),  country (code:"MR", name:"Mauritania"),  country (code:"MU", name:"Mauritius"),  country (code:"YT", name:"Mayotte"),  country (code:"MX", name:"Mexico"),  country (code:"FM", name:"Micronesia, Federated States of"),  country (code:"MD", name:"Moldova, Republic of"),  country (code:"MC", name:"Monaco"),  country (code:"MN", name:"Mongolia"),  country (code:"ME", name:"Montenegro"),  country (code:"MS", name:"Montserrat"),  country (code:"MA", name:"Morocco"),  country (code:"MZ", name:"Mozambique"),  country (code:"MM", name:"Myanmar"),  country (code:"NA", name:"Namibia"),  country (code:"NR", name:"Nauru"),  country (code:"NP", name:"Nepal"),  country (code:"NL", name:"Netherlands"),  country (code:"NC", name:"New Caledonia"),  country (code:"NZ", name:"New Zealand"),  country (code:"NI", name:"Nicaragua"),  country (code:"NE", name:"Niger"),  country (code:"NG", name:"Nigeria"),  country (code:"NU", name:"Niue"),  country (code:"NF", name:"Norfolk Island"),  country (code:"MP", name:"Northern Mariana Islands"),  country (code:"NO", name:"Norway"),  country (code:"OM", name:"Oman"),  country (code:"PK", name:"Pakistan"),  country (code:"PW", name:"Palau"),  country (code:"PS", name:"Palestinian Territory, Occupied"),  country (code:"PA", name:"Panama"),  country (code:"PG", name:"Papua New Guinea"),  country (code:"PY", name:"Paraguay"),  country (code:"PE", name:"Peru"),  country (code:"PH", name:"Philippines"),  country (code:"PN", name:"Pitcairn"),  country (code:"PL", name:"Poland"),  country (code:"PT", name:"Portugal"),  country (code:"PR", name:"Puerto Rico"),  country (code:"QA", name:"Qatar"),  country (code:"RE", name:"Réunion"),  country (code:"RO", name:"Romania"),  country (code:"RU", name:"Russian Federation"),  country (code:"RW", name:"Rwanda"),  country (code:"BL", name:"Saint Barthélemy"),  country (code:"SH", name:"Saint Helena, Ascension and Tristan da Cunha"),  country (code:"KN", name:"Saint Kitts and Nevis"),  country (code:"LC", name:"Saint Lucia"),  country (code:"MF", name:"Saint Martin (French part)"),  country (code:"PM", name:"Saint Pierre and Miquelon"),  country (code:"VC", name:"Saint Vincent and the Grenadines"),  country (code:"WS", name:"Samoa"),  country (code:"SM", name:"San Marino"),  country (code:"ST", name:"Sao Tome and Principe"),  country (code:"SA", name:"Saudi Arabia"),  country (code:"SN", name:"Senegal"),  country (code:"RS", name:"Serbia"),  country (code:"SC", name:"Seychelles"),  country (code:"SL", name:"Sierra Leone"),  country (code:"SG", name:"Singapore"),  country (code:"SX", name:"Sint Maarten (Dutch part)"),  country (code:"SK", name:"Slovakia"),  country (code:"SI", name:"Slovenia"),  country (code:"SB", name:"Solomon Islands"),  country (code:"SO", name:"Somalia"),  country (code:"ZA", name:"South Africa"),  country (code:"GS", name:"South Georgia and the South Sandwich Islands"),  country (code:"SS", name:"South Sudan"),  country (code:"ES", name:"Spain"),  country (code:"LK", name:"Sri Lanka"),  country (code:"SD", name:"Sudan"),  country (code:"SR", name:"Suriname"),  country (code:"SJ", name:"Svalbard and Jan Mayen"),  country (code:"SZ", name:"Swaziland"),  country (code:"SE", name:"Sweden"),  country (code:"CH", name:"Switzerland"),  country (code:"SY", name:"Syrian Arab Republic"),  country (code:"TW", name:"Taiwan, Province of China"),  country (code:"TJ", name:"Tajikistan"),  country (code:"TZ", name:"Tanzania, United Republic of"),  country (code:"TH", name:"Thailand"),  country (code:"TL", name:"Timor-Leste"),  country (code:"TG", name:"Togo"),  country (code:"TK", name:"Tokelau"),  country (code:"TO", name:"Tonga"),  country (code:"TT", name:"Trinidad and Tobago"),  country (code:"TN", name:"Tunisia"),  country (code:"TR", name:"Turkey"),  country (code:"TM", name:"Turkmenistan"),  country (code:"TC", name:"Turks and Caicos Islands"),  country (code:"TV", name:"Tuvalu"),  country (code:"UG", name:"Uganda"),  country (code:"UA", name:"Ukraine"),  country (code:"AE", name:"United Arab Emirates"),  country (code:"GB", name:"United Kingdom"),  country (code:"US", name:"United States"),  country (code:"UM", name:"United States Minor Outlying Islands"),  country (code:"UY", name:"Uruguay"),  country (code:"UZ", name:"Uzbekistan"),  country (code:"VU", name:"Vanuatu"),  country (code:"VE", name:"Venezuela, Bolivarian Republic of"),  country (code:"VN", name:"Viet Nam"),  country (code:"VG", name:"Virgin Islands, British"),  country (code:"VI", name:"Virgin Islands, U.S."),  country (code:"WF", name:"Wallis and Futuna"),  country (code:"EH", name:"Western Sahara"),  country (code:"YE", name:"Yemen"),  country (code:"ZM", name:"Zambia"),  country (code:"ZW", name:"Zimbabwe")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Reload the table
        //self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return countries.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell

        cell.textLabel?.text = countries[indexPath.row].name
        cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("jumpToProfile", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let index = self.tableView.indexPathForSelectedRow()?.row
        
        var destinationController: ProfileViewController = segue.destinationViewController as ProfileViewController
        
        destinationController.countryName = countries[index!].name
        destinationController.countryCode = countries[index!].code
    }
}
