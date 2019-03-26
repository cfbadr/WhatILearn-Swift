/*:
 # GetDestination
 
 ## Purpose
 The purpose of this playground is to display an map with two points and display the best itiniraire to go from one to the other one .
 
 ## Amelioration
 
 Change the source pin by gps position using `CoreLocation`
 */
import UIKit
import PlaygroundSupport
/*:
 We need to implement Mapkit framwork for display and work with a map. We use Maps and not GoogleMaps, because GoogleMaps is expensive.
 */
import MapKit

class MyViewController : UIViewController, MKMapViewDelegate {
    var mapView : MKMapView!
/*:
 Load view is a fonction from `PlaygroundSupport` we need to override it, in order to call our function.
 */
    override func loadView() {
        mapCordinatorFunction()
    }
    /*:
     `mapCordinatorFunction` is our main function who call the other part.
     */
    func mapCordinatorFunction() {
        let locationSourceTupple = (latitude: 48.814833, longitude: 2.422314) // Adresse gare metro
        let locationDestinationTupple = (latitude: 48.815457, longitude: 2.419873) // Adresse Neolynk

        let sourceLocation = convertTwoPointIntoCLLocationCoordinate2D(latitude: locationSourceTupple.latitude, longitude: locationSourceTupple.longitude)
        let destinationLocation = convertTwoPointIntoCLLocationCoordinate2D(latitude: locationDestinationTupple.latitude, longitude: locationDestinationTupple.longitude)

        loadMap(locationToZoom: sourceLocation)
        displayPinSource(location: sourceLocation)
        displayPinDestination(location: destinationLocation)
        findFastestWayToGoFromTheSourceToTheDestination(sourceLocation: sourceLocation, destinationLocation: destinationLocation)
    }

    func convertTwoPointIntoCLLocationCoordinate2D(latitude: Double, longitude: Double) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func loadMap(locationToZoom: CLLocationCoordinate2D){
        let view = UIView()
        let delta = 0.01
        let frame = CGRect( x:0, y:0, width:600, height:900)
        var region = MKCoordinateRegion()
        
        mapView = MKMapView(frame: frame)
        mapView.delegate = self
        region.center.latitude = locationToZoom.latitude
        region.center.longitude = locationToZoom.longitude
        region.span.latitudeDelta = delta
        region.span.longitudeDelta = delta
        mapView.setRegion( region, animated: true)
        view.addSubview(mapView)
        self.view = view
    }
    
    func centerMapOnLocation(location: CLLocation, mapView: MKMapView) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func displayPinSource(location: CLLocationCoordinate2D){
        mapView.addAnnotation(getPinAnnotation(location: location, title: "Gare métro"))
    }
    
    func displayPinDestination(location: CLLocationCoordinate2D){
        mapView.addAnnotation(getPinAnnotation(location: location, title: "Neolynk"))
    }
    
    func getPinAnnotation(location: CLLocationCoordinate2D, title: String) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title =  title
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        return annotation
    }
    
    func findFastestWayToGoFromTheSourceToTheDestination(sourceLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D) {
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        let directions = MKDirections(request: generateDirectionRequestForCalculateBestRoute(source: sourceMapItem, destination: destinationMapItem))
        directions.calculate {
            (response, error) -> Void in
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            let route = response.routes[0]
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveLabels)
        }
    }

    func generateDirectionRequestForCalculateBestRoute(source: MKMapItem, destination: MKMapItem) ->MKDirections.Request{
        let directionRequest = MKDirections.Request()
        directionRequest.source = source
        directionRequest.destination = destination
        directionRequest.transportType = .walking
        return directionRequest
    }
/*:
That fonction is called for design the route, color, with, etc ..
 */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        return renderer
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

