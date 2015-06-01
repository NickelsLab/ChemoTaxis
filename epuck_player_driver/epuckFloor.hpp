/* Copyright 2008 Renato Florentino Garcia <fgar.renato@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2, as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef EPUCK_Floor_HPP
#define EPUCK_Floor_HPP

#include "epuckInterface.hpp"
#include <vector>

/** \file
 *  Header file of EpuckFloor class and struct EpuckFloor::FloorData.
 */

/** Class for to get data from e-puck Floor sensors.
 *
 *  \author Renato Florentino Garcia.
 *  \date August 2008
 */
class EpuckFloor : public EpuckInterface
{
public:

  /// The number of Floor sensors on e-puck.
  static const unsigned SENSOR_QUANTITY = 8;

  /// Represents the data got from e-puck Floor sensors.
  struct FloorData
  {
    std::vector<float> voltages; ///< The raw Floor readings.
    std::vector<float> ranges;   ///< The equivalent obstacle distance.
  };


  /** The EpuckFloor class constructor.
   *
   * @param serialPort Pointer for a SerialPort class already created
   *                   and connected with an e-puck.
   *
   */
  EpuckFloor(const SerialPort* const serialPort);

  /** Read the Floor sensors.
   *
   * Read the values of Floor sensor from e-puck, and translate it for distance
   * in meters.
   * @return A FloorData struct with the read values.
   */
  FloorData GetFloorData() const;

  /** Give the geometry of each Floor sensor in e-puck.
   *
   * @return A std::vector with the sensors geometry.
   */
  inline std::vector<EpuckInterface::Triple> GetGeometry() const
  {
    return this->geometry;
  }

private:

  std::vector<EpuckInterface::Triple> geometry;
};

#endif
